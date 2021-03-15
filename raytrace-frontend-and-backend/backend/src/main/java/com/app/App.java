package com.app;

import java.io.File;
import java.io.IOException;
import java.net.ServerSocket;
import java.nio.file.Paths;
import java.awt.Color;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import javafx.util.Pair;
import java.net.Socket;

import java.io.PrintWriter;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import me.tongfei.progressbar.ProgressBar;

import org.apache.spark.*;
import org.apache.spark.api.java.function.*;
import org.apache.spark.streaming.*;
import org.apache.spark.streaming.api.java.*;
import scala.Tuple2;
import org.apache.spark.sql.SparkSession;
// import org.apache.spark.sql.Dataset;

public final class App {
    public static void main(String[] args) {
        // var sess =
        // SparkSession.builder().appName("SparkSessionExample").master("local[4]")
        // .config("spark.sql.warehouse.dir", "target/spark-warehouse").getOrCreate();
        var conf = new SparkConf().setMaster("local[*]").setAppName("Raytracing");
        var jssc = new JavaStreamingContext(conf, Durations.seconds(10));

        var lines = jssc.socketTextStream("localhost", 9999);
        // JavaDStream<String> words = lines.flatMap(x -> Arrays.asList(x.split("
        // ")).iterator());
        var scene = Config.scenes();
        final int TOTAL = Config.NX * Config.NY;

        JavaDStream<String> out = lines.flatMap(s -> {
            var list = Arrays.asList(s.trim().split(" "));
            final int nx = Integer.parseInt(list.get(0));
            final int ny = Integer.parseInt(list.get(1));

            return IntStream.range(0, nx * ny).mapToObj(idx -> {
                var i = idx / ny;
                var j = idx % ny;

                int[] color = scene.color(i, j, Config.NS, Config.DEP, nx, ny);

                return String.format("%d %d %d %d %d", i, j, color[0], color[1], color[2]);
            }).iterator();
        });

        var l = out.mapPartitions((part) -> {
            // Iterable<String> arr = rdd.collect();

            try (var socket = new Socket("localhost", 9999); var pw = new PrintWriter(socket.getOutputStream())) {
                // pw.println("WRITE");
                pw.flush();
                while (part.hasNext()) {
                    pw.println(part.next());
                }
                pw.flush();
            }

            return new ArrayList<Integer>().iterator();
        }).count();

        l.print();

        jssc.start(); // Start the computation
        try {
            jssc.awaitTermination(); // Wait for the computation to terminate
        } catch (InterruptedException ie) {
            System.err.println("InterruptedException");
            System.err.println(ie.toString());
        }

        jssc.close();
    }
}

class WithIndex {
    public Pair<Integer, Integer> pair;
    public int[] list;

    public WithIndex(Pair<Integer, Integer> pair, int[] list) {
        this.pair = pair;
        this.list = list;
    }
}
