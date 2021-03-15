package nativ;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map.Entry;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import com.google.common.collect.Iterables;

final class Common {
    static String minsec = ":00:00";

    static String extractDate(String log) {
        var splitted = log.split("\\s+");
        assert splitted.length > 4;
        // [12/Mar/2004:12:23:41
        var date = splitted[3];
        var length = date.length();
        return date.substring(1, length - Common.minsec.length());
    }

    static void handleException(Exception e) {
        System.out.println("Mapper: " + e.toString());
        System.exit(1);
    }
}

class MyMapper extends Mapper<LongWritable, Text, Text, Text> {
    private final Text keybuf = new Text();
    private final Text valuebuf = new Text();

    @Override
    public void map(LongWritable _lc, Text line, Context context) {
        String lineStr = line.toString().trim();

        var key = Common.extractDate(lineStr);

        keybuf.set(key);
        valuebuf.set(line);
        try {
            context.write(keybuf, valuebuf);
        } catch (Exception e) {
            Common.handleException(e);
        }
    }
}

class MyReducer extends Reducer<Text, Text, Text, IntWritable> {
    private final Text keybuf = new Text();
    private final IntWritable valuebuf = new IntWritable();

    @Override
    public void reduce(Text key, Iterable<Text> values, Context context) {
        keybuf.set(key.toString() + Common.minsec);
        valuebuf.set(Iterables.size(values));
        try {
            context.write(keybuf, valuebuf);
        } catch (Exception e) {
            Common.handleException(e);
        }
    }
}

public class App {

    // main throws Exception because I'm a lazy person
    public static void main(String[] args) {
        var conf = new Configuration();
        try {
            var job = Job.getInstance(conf, "word count");
            job.setJarByClass(Common.class);
            job.setMapperClass(MyMapper.class);
            job.setCombinerClass(Reducer.class);
            job.setReducerClass(MyReducer.class);
            job.setMapOutputKeyClass(Text.class);
            job.setMapOutputValueClass(Text.class);
            job.setOutputKeyClass(Text.class);
            job.setOutputValueClass(IntWritable.class);
            FileInputFormat.addInputPath(job, new Path(args[0]));
            FileOutputFormat.setOutputPath(job, new Path(args[1]));
            System.exit(job.waitForCompletion(true) ? 0 : 1);
        } catch (Exception e) {
            Common.handleException(e);
        }
    }
}
