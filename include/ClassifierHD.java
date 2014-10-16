/*
 * Copyright (c) 2010 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* for PostgreSQL's JDBC
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
*/

//import java.io.FileReader;
import java.io.BufferedReader;
import java.io.StringReader;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.analysis.tokenattributes.CharTermAttribute;
import org.apache.lucene.util.Version;
import org.apache.mahout.classifier.naivebayes.BayesUtils;
import org.apache.mahout.classifier.naivebayes.NaiveBayesModel;
import org.apache.mahout.classifier.naivebayes.StandardNaiveBayesClassifier;
import org.apache.mahout.common.Pair;
import org.apache.mahout.common.iterator.sequencefile.SequenceFileIterable;
import org.apache.mahout.math.RandomAccessSparseVector;
import org.apache.mahout.math.Vector;
import org.apache.mahout.math.Vector.Element;
import org.apache.mahout.vectorizer.TFIDF;

import com.google.common.collect.ConcurrentHashMultiset;
import com.google.common.collect.Multiset;

public class ClassifierHD {
	
	public static Map<String, Integer> readDictionnary(Configuration conf, Path dictionnaryPath) {
		Map<String, Integer> dictionnary = new HashMap<String, Integer>();
		for (Pair<Text, IntWritable> pair : new SequenceFileIterable<Text, IntWritable>(dictionnaryPath, true, conf)) {
			dictionnary.put(pair.getFirst().toString(), pair.getSecond().get());
		}
		return dictionnary;
	}

	public static Map<Integer, Long> readDocumentFrequency(Configuration conf, Path documentFrequencyPath) {
		Map<Integer, Long> documentFrequency = new HashMap<Integer, Long>();
		for (Pair<IntWritable, LongWritable> pair : new SequenceFileIterable<IntWritable, LongWritable>(documentFrequencyPath, true, conf)) {
			documentFrequency.put(pair.getFirst().get(), pair.getSecond().get());
		}
		return documentFrequency;
	}

	public static void main(String[] args) throws Exception {
		if (args.length < 5) {
			System.out.println("Arguments: [model] [label index] [dictionnary] [document frequency] [postgres table] [hdfs dir] [job_id]");
			return;
		}
		String modelPath = args[0];
		String labelIndexPath = args[1];
		String dictionaryPath = args[2];
		String documentFrequencyPath = args[3];
		//String tablename = args[4];
		String inputDir = args[5];
//		String jobID = args[6];
		
	        Configuration configuration = new Configuration();

		// model is a matrix (wordId, labelId) => probability score
		NaiveBayesModel model = NaiveBayesModel.materialize(new Path(modelPath), configuration);
		
		StandardNaiveBayesClassifier classifier = new StandardNaiveBayesClassifier(model);

		// labels is a map label => classId
		Map<Integer, String> labels = BayesUtils.readLabelIndex(configuration, new Path(labelIndexPath));
		Map<String, Integer> dictionary = readDictionnary(configuration, new Path(dictionaryPath));
		Map<Integer, Long> documentFrequency = readDocumentFrequency(configuration, new Path(documentFrequencyPath));

		
		// analyzer used to extract word from tweet
		Analyzer analyzer = new StandardAnalyzer(Version.LUCENE_43);
		
		int labelCount = labels.size();
		int documentCount = documentFrequency.get(-1).intValue();
		
		System.out.println("Number of labels: " + labelCount);
		System.out.println("Number of documents in training set: " + documentCount);

                try{
                        FileSystem fs = FileSystem.get(configuration);
                        FileStatus[] status = fs.listStatus(new Path(inputDir));
                        for (int i=0;i<status.length;i++){
                                BufferedReader br=new BufferedReader(new InputStreamReader(fs.open(status[i].getPath())));
                                String line;
                                StringBuilder txt = new StringBuilder();
                                while ((line = br.readLine()) != null) {
                                        txt.append(line+'\n');
                                }
                                br.close();

	                	String id = status[i].getPath().getName();
	                        String message = txt.toString();
	
	                        Multiset<String> words = ConcurrentHashMultiset.create();
	                        
	                        TokenStream ts = analyzer.tokenStream("text", new StringReader(message));
	                        CharTermAttribute termAtt = ts.addAttribute(CharTermAttribute.class);
	                        ts.reset();
	                        int wordCount = 0;
	                        while (ts.incrementToken()) {
	                                if (termAtt.length() > 0) {
	                                        String word = ts.getAttribute(CharTermAttribute.class).toString();
	                                        Integer wordId = dictionary.get(word);
	                                        if (wordId != null) {
	                                                words.add(word);
	                                                wordCount++;
	                                        }
	                                }
	                        }
	                        
	                        ts.end();
	                        ts.close();
	                        
	                        Vector vector = new RandomAccessSparseVector(10000);
	                        TFIDF tfidf = new TFIDF();
	                        for (Multiset.Entry<String> entry:words.entrySet()) {
	                                String word = entry.getElement();
	                                int count = entry.getCount();
	                                Integer wordId = dictionary.get(word);
	                                Long freq = documentFrequency.get(wordId);
	                                double tfIdfValue = tfidf.calculate(count, freq.intValue(), wordCount, documentCount);
	                                vector.setQuick(wordId, tfIdfValue);
	                        }
	                        Vector resultVector = classifier.classifyFull(vector);
	                        double bestScore = -Double.MAX_VALUE;
	                        int bestCategoryId = -1;
	                        for(Element element: resultVector.all()) {
	                                int categoryId = element.index();
	                                double score = element.get();
	                                if (score > bestScore) {
	                                        bestScore = score;
	                                        bestCategoryId = categoryId;
	                                }
				}
				System.out.println(message);
				System.out.println(" => "+ id + ":" + labels.get(bestCategoryId));
			}
                } catch ( Exception e ) {
                        System.err.println( e.getClass().getName()+": "+ e.getMessage() );
                        System.exit(0);
                }
		analyzer.close();
	}
}
