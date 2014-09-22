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

// for PostgreSQL's JDBC
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

import java.io.BufferedReader;
import java.io.FileReader;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.io.SequenceFile.Writer;
import org.apache.hadoop.io.Text;

public class PostgresToSeq {
	public static void main(String args[]) throws Exception {
		if (args.length != 2) {
			System.err.println("Arguments: [input tsv file] [output sequence file]");
			return;
		}
		String inputFileName = args[0];
		String outputDirName = args[1];
		Configuration configuration = new Configuration();
		FileSystem fs = FileSystem.get(configuration);
		Writer writer = new SequenceFile.Writer(fs, configuration, new Path(outputDirName + "/chunk-0"),
				Text.class, Text.class);
              	Connection c = null;
		Statement stmt = null;
		try {
		Class.forName("org.postgresql.Driver");
		c = DriverManager
			.getConnection("jdbc:postgresql://192.168.50.188:5432/uzeni","postgres", "dbwpsdkdl");
		c.setAutoCommit(false);
		System.out.println("Opened database successfully");
		stmt = c.createStatement();
		ResultSet rs = stmt.executeQuery( "SELECT * FROM WATER_KOREA_DUMP LIMIT 100;" );
		int count = 0;
		Text key = new Text();
		Text value = new Text();
		
		while ( rs.next() ) {
			String seq = rs.getString("seq");
			String rep = rs.getString("rep");
			String body = rs.getString("body");
			String category = rep;
			String id = seq; 
			String message = body;
			key.set("/" + category + "/" + id);
			value.set(message);
			writer.append(key, value);
			count++;
		}
		rs.close();
         	stmt.close();
         	c.close();
		writer.close();
		System.out.println("Wrote " + count + " entries.");
		} catch ( Exception e ) {
         		System.err.println( e.getClass().getName()+": "+ e.getMessage() );
         		System.exit(0);
       		}
	}
}
