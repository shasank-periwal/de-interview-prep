# SPARK
```python
spark-submit
-- class my.great.app \ # [OPTIONAL] only for code written in JAVA or SCALA
-- master [k8s://11.22.33:404, local[3]] \ # how it would run in our machine
-- deploy-mode [client,cluster] \# In cluster, the Spark Driver is part of the cluster, runs in one of the DataNode, in client it acts a client
-- jars C:\my-sql-jar\my-sql-connector.jar \
-- conf spark.dynamicAllocation.enabled = true \
-- conf spark.dynamicAllocation.minExecutors = 1 \
-- conf spark.dynamicAllocation.maxExecutors = 10 \
-- conf spark.sql.broadcastTimeout = 3600 \
-- conf spark.sql.autoBroadcastJoinThreshold = 10000 \

-- driver-memory 20G \
-- driver-cores 4 \

-- num-executors 3 \
-- executor-memory 20G \
-- executor-cores 4 \

-- py-files spark-session.py, logging.py \ #python files reqd for our program to work
-- files config.py \ #other files required for the program to work
testing-ontology dev #these are args that can be accessed by argv[0], argv[1], ..
```

### Hadoop VS Spark
| Hadoop                                                                                              | Spark                                                                                                                 |
| ----------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------- |
| Hadoop is slower because there's disk involved. Reads and write to disk even the intermediate data. | Spark is faster because of in-memory processing. Reads and write in-memory.                                           |
| Batch only.                                                                                         | Batch and streaming.                                                                                                  |
| Uses Kerberos Authentication and ACL(Access Control List) Authorization.                            | No native authentication/authorization. Uses HDFS- gives ACL Authorization, uses YARN- gives Kerberos Authentication. |

### What is spark?
    Spark is a unified computing engine.
    Apache Spark is an open-source, distributed computing system designed for fast and general-purpose data processing. It's especially well-suited for big data workloads because it processes data in-memory, which significantly boosts performance compared to traditional disk-based processing frameworks like Hadoop MapReduce.

### What is a cluster?
    A pool of computers working together but viewed as a single system.

### Isn't Spark a framework?
    Technically, Apache Spark is a unified analytics engine that includes a framework for distributed data processing. It provides a comprehensive set of tools and APIs that allow developers to build and run data processing pipelines at scale. So while we often say “framework”, Spark also acts as an execution engine, a scheduler, and an abstraction layer over distributed computing.
    In short, it’s fair to call Spark a framework — but it’s also an execution engine with its own internal DAG scheduler, memory manager, and task orchestration system that makes it much more powerful than a typical application framework.

### What spark does
    We submit the spark app to the Cluster Manager(CM Example- Yarn, Mesos, Kn8s, Standalone) it then reaches out to NM(Node Manager) where if the reqd driver constraints are satisfied, then it launches a spark driver process(JVM- Java Wrapper and PySpark- Python Wrapper(if the application is written in Pyspark)) in a *Worker Node* which then loads the executors in one or more nodes. It's not necessary to that all the EP(Executor Processes) will be in one node. In all the executors JVM is loaded and PySpark Wrapper(if there are UDFs, which suggests that we shouldn't use UDF) 
    It is used for OLAP.

### FLOW
- Query
- → Unresolved Logical Plan
- → Spark SQL Engine/Catalyst optimizer
  - → ANALYSIS- [goes through a Catalog(metadata)] Analyzed Logical Plan(Resolves column name, datatype)
  - → LOGICAL PLANNING- Optimized Logical Plan
  - → PHYSICAL PLANNING- Selects one of many Physical Plan based on cost
  - → CODE GENERATION- Generates Java code. 
- → RDD/Javabyte code sent to all the executors(df.codegen())

### READ command
```python
df = spark.read.format("csv") \
          .option("mode", "failfast") \
          .option("inferschema", "true") \
          .option("skipRows", 1) \ #how many lines to skip in the file
          .option("header", "true") \
          .path("/directory/filename.csv")
```

### MODE- Handling corrupt files:
| MODE                       | BEHAVIOR                                                                                                |
| -------------------------- | ------------------------------------------------------------------------------------------------------- |
| **permissive** *(default)* | Loads corrupt/malformed records as `null` or places them in a special column (e.g., `_corrupt_record`). |
| **failfast**               | Immediately throws an exception if it hits a bad record.                                                |
| **dropmalformed**          | Silently **drops** malformed records from the output.                                                   |

- `_corrupt_record` column name can be changed by-  `spark.sql.columnNameOfCorruptRecord`
-   `badRecordsPath` is only a Databricks specific feature.

### WRITE command
```python
df = df.repartition(3).write.format("csv") \
          .option("header", "true") \
          .option("mode", "overwrite") \ #types- append, overwrite, ignore(doesn't write), errorIfExists
          .partitionBy("column_name1", "column_name1") \
          .save("/directory/filename.csv")
          
          .bucketBy(3, "column_name") \ # no_of_buckets, column_name
          .saveAsTable("table_name") # save doesn't work with bucket since spark needs to store the info in Hive Metastore
```


### RDD vs Dataset vs Dataframe
-   RDD- Resilient Distributed Dataset. 
    -   Resilient because it is fault tolerant, since it stores the data lineage and if any error occurs it can start again. 
    -   If code is written in RDD it doesn't do any optimization. 
    -   It is immutable and hence new RDDs are created after every transformation. **How to**
    -   Advantage is when we work with un-structured data. Rest two structured.
    -   If error in code, gives compiler time error. Rest two runtime.
-   DataFrame - Built on top of RDD, does optimization using Catalyst Optimizer. **What to**
-   Dataset- provides type safety(Present in scala), it can push down many filter condition to your source, even efficient than Kryo-Serializer.

##### NOTE: If we write code using RDD/Dataframe, it takes more time since it serializes/deserializes the code from/to Java, hence not very memory efficient.

### Types of Transformation:
-   Narrow dependency: Transformations that do not require data shuffling between partitions. Ex: Union, Filter, Map, Select, etc.
-   Wide dependency: Transformations that require data shuffling between partitions. Ex- groupby, orderby, reducebykey<br>
**Transformation vs Action**- Spark is lazy, transformation are not immediately done, these are only done after we call an action.

### JOB - STAGE - TASK
    → Job- How many actions we call when we write our Spark program.
    → Stage- When we use a wide transformation, data is shuffled and a new stage is created. No of stage- (No. of wide transformation + 1)
    → Task- Individual action on the data. No of partition = No of tasks. Map→ Filter→ ReduceBy, these are tasks.

### STAGES 
-   Depends on the number of shuffle operations we have in the code
-   A task is a unit of computation applied to a single partition on a single executor.
-   An executor with four CPU cores and eight partitions can only have four tasks running in parallel.
-   **Each time spark has a shuffle, it'll create 200 parititions by default**
-   *spark.conf.set("spark.sql.shuffle.partitions", 50)*

### BUCKETING vs PARTITIONING - 
    If we need to partition a column, but doing it may end up with small file problem then use bucketing, we give the number of buckets and then the data gets divided by a hash function. It's different in Hive and Spark, Hive goes through Reduce and Spark through map.

    ❌ Too few partitions → Tasks take longer due to low parallelism and high memory pressure.
    ❌ Too many partitions → Overhead increases, and Spark spends more time scheduling than executing.
    ✅ Optimal partitioning balances parallelism and task overhead for best performance.
    A common rule of thumb: Aim for ~200MB per partition and adjust based on workload.

#### ISSUES WITH BUCKET BY
    If there are X number of tasks and we made Y buckets, then the total number of buckets will by XY
    To overcome this we repartition | df.repartition(Y).write
    Bucketing avoids shuffle when we join two like tables.(same bucket column, same number of buckets)
    Bucket Pruning(term to remember)
    
### RE-PARTITION vs COALESCE
    → Coalesce results in narrow dependency(tries to avoid shuffle/merges two or more partition), repartition adds a shuffle step. 
    → If we do a drastic coalesce, let's say 1, then computation would be done on one node and not parallely, to avoid this we can use repartition, which would result in shuffle and hence the current upstream tasks would be done in parallel. 
    → To increase partition we generally use Repartition(can also decrease), to decrease we use Coalesce.
    → If we give more partition than it already is in coalesce, then it keeps the same, doesn't give any error.
#### WHEN TO USE
>`COALESCE-` Optimizing after a heavy filter: Reduces the number of partitions with minimal overhead to speed up subsequent operations.	<br>
>`REPARTITION-` Balancing data skew: Redistributes data evenly after operations like joins or when increasing partitions to prevent bottlenecks.
#### HOW TO USE
```python
df.rdd.getNumPartitions()
df.repartition(number_of_partition, column_name) # works together, either or as well
df.coalesce(number_of_partition) #cannot increase partition even if given
```

### ADE- Adaptive Query Execution framework
    Lets's say Stage 1 reduces the data but since the physical plan has been generated, Stage 2 would be considering the outdated one, to solve this AQE was introduced in Spark 3, which optimizes the plan after each stage
    Does the following
    1. Dynamically coalescing shuffle partitions.
    2. Dynamically switching join strategy.
    3. Dynamically optimizing skew join.
    spark.conf.set("spark.sql.adaptive.enabled", true)

#### VECTORIZED READER
    Vectorised Parquet file reader is a feature added since Spark 2.0. Instead of reading and decoding a row at a time, the vectorised reader batches multiple rows in a columnar format and processes column by column in batches.
    ✅ Advantages- Performance Boost, Reduced Memory Usage, Better CPU Utilization, Faster I/O, Optimized for Columnar Formats
    ❌ Disadvantages- Higher Memory Requirement, Nested structures may not be fully optimized, may not improve performance for small datasets or non-columnar formats.
    spark.sql.parquet.enableVectorizedReader

### JOINS
- left_semi: Only those which are **similar in both tables** and columns of left table.
- left_anti: Only those which are **not similar in both tables** and columns of left table.
- crossJoin

#### JOIN STRATEGIES
- Shuffle Sort Merge: Exactly what the name suggests.(CPU is utilised in sorting) **default**
- Shuffle Hash: Hash is made of the smaller table and then compared with the other table. (Memory is utilised here)
- Broadcast Hash: Sends data to all nodes via variable. Hash same concept as before. **10MB by default**. `spark.conf.set(spark.sql.autoBroadcastJoinThreshold) in bytes` 
- Cartesian:
- Broadcast Nested Loop: When there's a condition `df.age <= d2.age`.

#### How to build schema from string
    from pyspark.sql.types import _parse_datatype_string
    _schema_str_3 = "id int, name map<string, string>, subject array<string>"
    _schema_3 = _parse_datatype_string(_schema_str_3)

#### Why to refresh table
    Spark SQL caches Parquet metadata for better performance. When Hive metastore Parquet table conversion is enabled, metadata of those converted tables are also cached. If these tables are updated by Hive or other external tools, you need to refresh them manually to ensure consistent metadata.
    spark.catalog.refreshTable("my_table") -- spark is an existing SparkSession

### CACHE AND PERSIST
    Persists has different storage level(Default MEMORY_AND_DISK, others= MEMORY_AND_DISK_SER, MEMORY_ONLY_SER, DISK_ONLY).
    SER only works in JAVA/SCALA.
    To change storage level we need to unpersist() and re-persist.
    Cache is wrapper on persist with only storage level MEMORY_AND_DISK.
    When we use .show(), it shows data from only one partition. Hence df.cache().show() only caches 1/n partitions.
    When we use .count(), it shows data from all the partitions. Hence df.cache().count() caches all partitions.

### Types of Resource Allocation
1. **Static Resource Allocation**- Keeps the resource(memory) even if after stages the memory is not utilised.
2. **Dynamic Resource Allocation**- Frees the resource(memory) if after any resource the memory is freed by the Job.
    - Catch being if the job demands the resource again and the cluster cannot provide it, then the job would fail.
        - The above issue can be neutralised by setting minExecutors and maxExecutor while submitting the spark job.
    - Let's say the executor is freed but the disk contains data because of read and write exchange in this case that'll also get deleted.
        - The above issue can be solved by a parameter `spark.shuffleTracking.enabled = true` which keeps the data even after free-ing.

### DPP- Dynamic Partition Pruning
Issue: Let's say `table_a` is partitioned on the basis of date and has to be `joined` with `table_b` which has `filter` condition based on dates, then `table_a` would be read fully since it's not filtered. To overcome this challenge there's `DPP` which is done in `runtime` and is by default enabled in Spark >= 3.0.<br>
Only works when
-   Data is paritioned
-   2nd table is broadcast-able.

### Out of Memory (OOM)
##### Driver OOM
    spark.driver.memory- JVM Process
    spark.driver.memoryOverhead - Non JVM Process. 10% of above or 384MB whichever is higher. Container's metadata process will run in this.

    Reasons for Driver OOM-
    collect() is used
    broadcast

##### Executor OOM
    spark.executor.memory- JVM Process
    spark.executor.memoryOverhead- 
        Non JVM Process(PySpark's JVM etc). 
        10% of above or 384MB whichever is higher. 
        Container's metadata process will run in this.
        600-700MB will be used by PySpark JVM.


If we encounter OOM in Spark → then we can re-persist our dataframe→also could be because of data skewness

- Q) If spark is in memory processing why do we need caching?
    - Caching is used to store intermediate df to the memory so that the df is not calculated again.

- Q) Give a break-up of Spark's Memory.
    - 60%: ***Spark Memory***: 50%-50%→one is used for computation and the other 50 is used for caching etc
        - 50%- **Storage Memory Pool**: Storing intermediate state, **cache** is stored.
        - 50%- **Executor Memory Pool**: Storing objects used during execution. Hash is stored here.
    - 40%: ***User Memory***, etc. User Defined DataStructures/Functions, spark internal metadata. Raw RDD is also calculated here.
    - ***Reserved Memory***: 300MB. Used by Spark engine/to store internal objects

- Q) Why can executor sometimes not spill data to disk and raise OOM?
    - When the data is skewed and the storage memory pool is used in full capacity then if one of the partition's size is > executor memory, it can never execute that. Can be fixed by salting and repartition.

- Q) Types of Memory Manager?
    - Static Memory Manager- Old. Hard limit in terms of percentage between Storage and Executor Memory Pool.
    - Unified Memory Manager- New. Soft limit between Storage and Executor Memory Pool. If one is free other can use.

### Garbage collection (GC)
It is indeed a critical performance factor in Apache Spark that can significantly impact query execution. Since Spark runs on the JVM and relies heavily on memory operations, inefficient GC can cause substantial slowdowns and even failures.

How to Know If GC Is Affecting Your Query
Check the Spark UI
The easiest way to identify GC issues is through the Spark UI. Navigate to the `Executors` tab where Spark will mark executors in red if they have spent more than 10% of their time on garbage collection. This visual indicator immediately tells you which executors are experiencing GC pressure.
Memory Management Problems
- Too many small objects: RDDs/DataFrames with millions of small objects that aren't properly released
- Large shuffles: Wide transformations like groupByKey() or joins consume excessive memory
- Inefficient caching: RDDs/DataFrames cached but not properly managed or cleared
- Long-living objects: Broadcast variables or accumulators not cleaned up after use


### WINDOW FUNCTIONS
- first
- last
<br>**DEFAULT**- `rangeBetween(Window.unboundedPreceding, Window.currentRow)` (**NOT** `rowsBetween`)

### Good to know
1. DF are immutable   
2. Spark lets each node know what transformations to do. (Data Locality Principle) 
3. df.explain("formatted")- prints the data lineage 
4. Lineage is the logical plan whereas DAG is the physical plan with stages etc.
5. There can be multiple Spark Session for a Spark Context(represents one application, SparkSession arrived in Spark2.0)
6. In Apache Spark, the spark.read.csv() method is neither a transformation nor an action; spark.read.csv() is a method used for initiating the reading of CSV data into a Spark DataFrame, and it's part of the data loading phase in Spark's processing model. The actual reading and processing of the data occur later, driven by Spark's lazy evaluation model.
7. If you don't explicitly provide a schema, Spark will read a portion of the data to infer it. This triggers a job to read data for schema inference. If you disable schema inference and provide your own schema, you can avoid the job triggered by schema inference.

### Functions
```python
df.select(col("col_name.sub_name"), column("col_name.sub_nmae"), df.col("col_name"), expr("concat(first_name, last_name) name"))
.withColumnRenamed("name", "new_name")
.drop_duplicates(["col1","col2","col3","col4"])
.sort(col("col_name").desc)
.withColumn("name", lit("a value for all the rows"))
.write.saveAsTable("tbname")
```

### [🛠️ Resource](https://youtube.com/playlist?list=PLTsNSGeIpGnFiErPovNizG_2IP2RvrgnK&si=Q7HRF61a0TjsZaXM)