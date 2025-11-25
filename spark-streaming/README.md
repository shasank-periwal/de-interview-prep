## SPARK STREAMING

#### How does Spark Streaming work?
    Spark Streaming breaks down data into micro batches to enable batch code on streaming data.
    Spark appends the incremental data as batches to a dataframe and utilizes the same code as that of batch processing.
    By default spark uses the name 'value' for a column.


#### Useful Spark-Streaming configs
- config("spark.streaming.stopGracefullyOnShutdown", True) 
    - makes sure the processes are completed and then spark shuts down
- config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.3.0") 
    - required to enable kafka in Spark Streaming
- config("spark.sql.streaming.schemaInference", True)
- spark.conf.set("spark.sql.streaming.schemaInference", True)

#### Watermark and what in means in context of Spark-Streaming.
    Watermark has to do with time. It means how back can a query be considered.
    Example- At 12:17 with Watermark set to 10 mins if a query comes with timestamp >= 12:07 then it'll be considered else discarded. 
    .withWaterMark("event_time", "10 minutes") = events that happened before 10 mins will be discarded 

#### STREAMING OUTPUT MODES
-  Complete- It considers the whole list of words in case of WORD COUNT program.
            This doesn't take watermark into consideration. Hence we don't use the .withWatermark with complete mode
-  Update- It considers only the new ones and shows the ones that changed. Not all sinks support this ex-.txt files
-  Append- 

#### Folders that are auto created when using Spark Streaming.
- Sources- Spark keeps track of the source in the sources folder.
- Offset- Data which has been read and processed is being taken care by the offset folder.
- Commit- Once data is processed it puts it into commit.

    Fault tolerance can be achieved by offset and commit, if a file has offset but has not been committed yet, then the data is not yet processed.
    Need to run a failed task, remove it from the sources.

#### TRIGGER TYPES
- .trigger(once=True)
    - Once/availableNow Mode- It will still read the data in Incremental mode but will not trigger continuously in micro batches — rather, it processes new data in a single go and then shuts down.
    - Acts as batch pipeline(Kappa architecture 101)
- .trigger(processingTime='10 seconds')
    - Processing Time- Will trigger in micro batch fashion.
- .trigger(continuous='10 seconds')
    - Continuous- This will run continously, the 10 seconds means that the checkpoint will be updated every 10 seconds

#### forEachBatch
    There's an issue when we write to two or more different sinks. Issue being one could be faster than other and both could have different offsets and checkPointDir. Also number of write statements = number of times the data would be calculated(whole code would run).
    To address the above issue there's a function
    forEachBatch(python_function).option("checkpointLocation", "checkpoint_dir").start()
    
    def python_function(df, batch_id):
        df.write..
        df.write..

#### STATEFUL PROCESSING
    Spark holds data for a certain amount of time, after which it'll discard data that comes.

#### Window Type in Spark Streaming:
1. Tumbling (Fixed) Window: These are non-overlapping windows. Each event belongs to exactly one window.
2. Sliding (Overlapping) Window: These are overlapping windows that "slide" over time. An event can belong to multiple windows.
3. Session Window: Windows are defined by a period of inactivity (a session gap). Useful when events come in bursts, with unpredictable timing.
    
    ##### How to work with Window
                                    Window size   Overlapping interval
        .groupBy(Window("event_time", "10 minutes", "5 minutes"))

#### CHECKPOINTING
1. How to cache a streaming dataframe?<br>
    - Use Checkpointing for State Management<br>
    Spark Structured Streaming uses checkpointing to maintain state and recover from failures. <br>
    While this doesn't cache the DataFrame like persist(), it provides fault tolerance.

``` scala 
val query = processedDF.writeStream
  .format("console")
  .option("checkpointLocation", "/path/to/checkpoint")
  .start()
```

#### EXTRAS 
    ncat -l 9999 → start listening/producing on port 9999
    Kafka sends data in binary we need to cast those binary data to string
    How to tune the kafka job if its running slowly? Increase num of paritions to enable parallelism
    Event Time VS Processing Time

### [🛠️ Resource](https://youtube.com/playlist?list=PL2IsFZBGM_IEtp2fF5xxZCS9CYBSHV2WW&si=EcidqdIE6DUpfPRH)
