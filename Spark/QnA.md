## UNION
Union vs Union All: Differences in Spark and SQL- In PySpark both are same. <br>
When two tables have **different order** of column, in PySpark **no error** is given, records are merged as is.<br>
To tackle the above issue use **unionByName**, it unions basis the column name. [intelligent]<br>
When two tables have **different structure** of column **error** is given.<br>

## JSON (and/in Spark)
Types of JSON(Javascript Object Notation)
- Line Delimited: 
    ```
    {"key": "value", "key": "value"}
    ```
- MultiLine: 
    ```
    {
        "key": "value", 
        "key": "value"
    }
    ```
Spark by default accepts and works faster on Line Delimited because there's no computation overhead. JSON ends where a line ends which is not the case with multi-line JSON because it needs to find the end.
`.option("multiline", "true") `

## NOTES

When array, ***explode***. When using explode if the column has NULL values it returns the row as NULL. Use ***explode_outer*** in that case.<br>
When struct, ***[dot] notation***.<br>

When deploy-mode = `client`, then the driver is started in edge-node itself. `Drawback- Network latency` <br>
When deploy-mode = `cluster`, then the driver is started in one of the worker node. Gives an `application-id` that we can use to see the stats of the application.<br>

#### GET COLUMNS FROM DATAFRAME OR STRUCTTYPE
`df.columns` - gives us a list of columns
`target_schema: StructType` - target_cols = [f.name for f in target_schema.fields]


#### SCHEMA EVOLUTION
Open-Table Formats(Hudi, Iceberg) auto manages schema-evolution.
Parquet - If using `Spark`, set `.option("mergeSchema",True)`, Spark will combine all the schemas while reading. If we want to handle schema on write, in that case use `lit(None).cast(target_schema[col_name].dataType)`.


## QnA
1. By default how many files will the dataframe be written into? 
    > If shuffle, 200.
2. If it doesnt have the shuffle step then how many files?
    > The number of files created = number of partitions in the DataFrame after read.csv(), which depends on input file splits and cluster configuration, and is typically more than 1 for large input or 1 for small input.
3. You need to move data from multiple sources (CSV, API, database) into a data warehouse daily. How would you design the pipeline?
4. A downstream analytics team is reporting incorrect data. How would you investigate and resolve the issue?
5. You are given a terabyte-sized dataset with frequent updates. How would you design a scalable system to track changes over time?
6. A Spark job is running slower than expected. What steps would you take to diagnose and optimize it?
7. You're asked to integrate real-time event data into an existing batch processing architecture. How would you approach this?
8. The business wants to track user activity in near real-time. What technologies and architecture would you propose?
9. One of your ETL jobs failed midway and caused partial data load. How would you handle data consistency and rerun logic?
10. You need to implement data versioning in a pipeline where schema changes are expected. How would you handle this?
11. There's a requirement to mask sensitive data in your pipelines. What would your approach be?
12. You receive JSON data with inconsistent structure from an API. How would you process and store it reliably?
13. You're asked to design a data lake strategy for a financial services product. What factors will you consider?
14. The data team is struggling with long-running joins in Hive. What optimizations would you suggest?
15. A batch job is processing daily logs but has to be backfilled for the past 3 months. How would you handle this efficiently?
16. You are joining two large datasets (100M+ records each) and running into memory errors. What's your approach?
17. You must ensure data lineage and auditability for every transformation step. What tools or frameworks would you use?
18. When can a data be considered skewed in Spark?
    > If the data is 5x of median data and size is greater than 256MB.
19. What does an action do? 
    > Triggers job, executors sends all the respective data to driver. So if the total size is 15GB but the driver's size is 10GB, we'll get an error.
20. Usecase of repartition?
    > To increase or reshuffle partitions for better parallelism or data distribution.
21. Causes of silent Spark job failures.
    >  ***Executor or Driver Memory Limits***: If the spark.executor.memory or spark.driver.memory settings, along with spark.executor.memoryOverhead, are insufficient for the workload, the JVM process for an executor or driver can exceed its allocated memory and be killed by the operating system or resource manager (e.g., YARN, Kubernetes) without Spark explicitly catching and reporting a java.lang.OutOfMemoryError.<br>
    ***Garbage Collection Pauses***: Excessive garbage collection (GC) activity, especially with large heaps, can lead to long pauses in the JVM. If these pauses exceed heartbeat timeouts, the driver might assume the executor is lost and terminate it.<br>
    ***Executor Heartbeat Interval***: If executors fail to send heartbeat signals to the driver within the spark.executor.heartbeatInterval or spark.network.timeout due to high load, network issues, or long GC pauses, the driver will mark them as lost, leading to job termination.
    
22. How to decide number of executors and size? [Explanation](https://youtu.be/1TmpZnOWdqY?si=sdtfYfBvjGawNWSb)
    #### REVERSE CALCULATION
    ```
    Do reverse calculation - which is almost correct.
    Assuming I've 128GB RAM and 48 Core; 16 machines. 2 are master nodes(1 standby), so we are left with 14 machines.
    1GB RAM and 1 Core reserved for driver.

    - 128-1 = 127*14 = 1778 GB = 1.8TB RAM
    - 48-1  = 47*14  = 658 cores ~ 650 core

    5 Core/executor = 650/5 = 130 executors
    Avg memory per executor = 1778/130 = 14GB RAM
    Overhead exclusion(i.e., 10% of memory or 384MB, whichever is higher)
    = 14GB - 1.4GB = 12.5GB/executor; 5 Core/executor

    Above calculation is for ideal world.
    ```
    #### ACTUAL WAY
    ```
    1. Requirement Gathering-                                  | The below aren't solution these are just starting point
        - Type of data.                                        | If data > 50 GB start with 25GB RAM
        - Type of transformation.                              | If data = 1GB, 4GB RAM
        - Single vs Multiple Sources.                          | If data = 10GB, 20GB RAM
        - Avg SLA.                                             | When the data volume is high, we can work with low size.
    2. Cluster Configuration(If they have one)                 | When the data volume is low, we need to work with more size.

    Approach 1. 
        15GB RAM/Executor
        5 cores
        4 executor machine.
        = 60GB RAM --which will be nearly half of data
            ├── 1.2GB Reserved Memory
            ├── 60% of 60GB = 36GB -- spark memory
            └── 40% of 60GB = 24GB -- user memory
        We can play around with the percentage to get the correct value as per our need.

        Therefore, max calculation that can be done is 36GB and if caching comes into play it'll range from 18GB-36GB
        So, max iteration = 110GB/(18GB/2) = 14 -- divided by 2 because in memory it will be stored as deserialized object.
            min iteration = 110GB/(36GB/2) = 8
    ```
23. Size of data you have worked with. 
    ```
    Set a limit of 2MB per file
    Taking ~ 1.5MB per file
    per table ~ 20 files
    20 * 1.5 = 30MB
    Nearly 190 tables
    30 * 190 = 5700 = 5.6GB
    ~ 50 columns
    ~ 5 rows
    ```

24. If a job still fails after all retries, how is it handled?
    >After exhausting retries, the job's final failure triggered an Airflow SLA miss alert and moved the workflow into a paused state.

25. How would you design a pipeline that runs every hour without fail?

    >Runs every hours: means that the data is compartively smaller. We just need to make sure the flow stays well. 
    >- Idempotency First: The pipeline must be designed so that running it multiple times with the same input produces identical results.
    >- Multi-Layer Retry Strategy:
    >    - Task-level retries: Configure 3-5 retries with exponential backoff.
    >    - Exponential backoff prevents thundering herd problems when external services are down
    >    - Circuit breaker pattern
    >- Partition-Based Processing: Since its hourly, partition the output by hour and use INSERT OVERWRITE instead of append operations.
    >- Checkpointing: Implement intermediate checkpoints.
    >- SLA Definition: Set clear expectations. Configure alerts.
    
26. How would you design a data pipeline to handle daily logs from multiple sources?
    > Can have data from various sources like EC2, Lambda etc and the status of it. Reading and generalizing the schema.

27. How do you handle schema evolution in a Parquet file?
    > Leverage Parquet Merge Schemas on Read - so that only files which won't have those particular field will be populated with NULL. Tools like Delta Lake, Apache Iceberg, and Hudi provide built-in schema evolution.

28. How do you handle late-arriving data in a batch pipeline?
    >Watermark, merge statements etc.

29. Explain a situation where you had to clean and transform messy JSON data.
    >NCB's data. mlt_vl number.

30. 10k files. What next, where does it go? Errors handled how? SLA? What was the data about? Cost?
    >Policy numbers. BI Folks, to the dashboard. Retries. 15 mins. 

31. - Issues/Trade-offs after shifting Glue Jobs to EMR. Job failed or something?
    - When running something on EMR, where can we see the logs?
    >Complexity increased. Usually run EMR on cluster mode, downside being the logs can't be seen, upside being the task runs very fast. After running in Client mode, we can see the logs in EMR logs. History server. EMR UI Console → Summary → Log URI. Yarn.

32. SQS → Lambda → Failed. What now?
    >- Message Visibility Timeout
    >    - When Lambda reads a message from SQS, the message becomes hidden (visibility timeout) for a configured period (default 30 seconds).
    >    - If Lambda fails (error or timeout), the message remains invisible until the visibility timeout expires.
    >    - After expiry, the message becomes visible again for processing (retry).
    >- Retries by Lambda Service
    >    - The message will be re-delivered to Lambda for retries until either:
    >    - The Lambda invocation succeeds, or
    >    - The message’s ReceiveCount exceeds the maxReceiveCount configured on the SQS queue’s Dead Letter Queue (DLQ) redrive policy.
    >- Dead Letter Queue (DLQ) Handling
    >    - If the maxReceiveCount is reached (e.g., 5 retries), the message is automatically moved to the configured SQS DLQ or SNS topic for failed messages.

    <br>
33. - Tell me a time when bad data reached production — and how you fixed it.
    - Give instances of wherein something fatt gaya and you had to take care of it.
    - Tell me about a pipeline you built in production and share some scenarios where things went wrong.
    ```
    BI Folks saw higher than usual policy count - Policy records deduplicated on the basis of policy_id.
        Root Cause: We had implemented a new policy amendment processing system that was creating additional policy records instead of updating existing ones. Our deduplication logic was based on policy_number alone, but the upstream system started appending suffixes like -01, -02 for amendments (renewals, coverage changes, endorsements).
    ```

34. What are the transformations you do?
    ```
    Mirror - Create a copy of data that stores only the latest record, 
    PSA - Persistent Staging Area
        Metadata Columns - Timestamp, source table etc
        CDC capture
        Business Logic
        Flattening Data
    ```

35. - Types of data quality checks, also before or after triggering the pipeline?
    - What type of checks/tests in the pipeline?
    > Below are some of the tranformations which are done-
    - ***Data Quality Checks***
       - **Schema Validation**: This catches upstream changes early before they break downstream processes.
       - **Completeness Checks**: I verify that mandatory fields aren't null or empty. 
       - **Range and Format Validations**: Premium amounts must be positive, dates must be valid and within reasonable ranges, phone numbers match expected patterns. 
    - ***Business Rule Validations***
        - **Domain-Specific Logic**: In insurance, I check things like coverage amounts being reasonable for the policy type, effective dates not being in the future, renewal policies having valid previous policy references.
        - **Anomaly Detection**: I track patterns over time - if today's policy count is 30% higher than the 7-day average, something's probably wrong. 
    - ***Volume and Freshness Checks***
        - **Record Count Validations**: I compare expected vs actual record volumes. If I typically process 50,000 policy updates daily but only see 5,000, that's a red flag.
    - ***Recon Jobs*** - Check if the record exists backward and no data is lost.

36. What challenges have you faced while implementing the pipeline? And how did you resolve?

    >- Memory Management and OOM errors
    >- Lessons Learned
    >   - Monitor Everything: You can't fix what you can't see. Comprehensive logging and monitoring are non-negotiable.
    >   - Design for Failure: Assume things will go wrong. Build retry logic, circuit breakers, and graceful degradation from day one.
    >   - Business Context Matters: Technical solutions need to align with business processes. Spend time understanding the domain.


37. What is the business use case that you are solving?
    ```
    We needed to generate statutory reports
    Real Time and Batch dashboards
    C360 dashboard - Holistic view of customer.
    ```

38. Does non-ASCII character cause issue? 
    >In PySpark, whether non-ASCII characters in a header cause issues depends on a few things-
    - File Encoding
        - If the file is UTF-8 encoded (most common in modern systems), then headers with non-ASCII characters (like café, नाम, 客户) will usually load fine.
        - If the file is in another encoding (e.g., latin1, cp1252) and you don't specify it, Spark may misinterpret the characters.
    - Column Naming Rules
        - Spark technically allows Unicode in column names, but some operations break:
        - Using such columns in SQL expressions without quoting may fail.
        - Some connectors (JDBC, Hive Metastore, Parquet readers) may not handle them cleanly.

39. Why did comparison between HUDI, Iceberg and Delta Lake only. What problems do they solve that Hive cannot?
    >Open Table Format has a metadata layer that utilizes the low-cost nature of blob storage and gives ACID properties on top of it whereas Hive is a query engine that stores the metadata for the tables stored in HDFS. Hive is a query engine; Open Table Format is metadata layer, we can't query from Open Table Format.As datasets grow (millions of partitions, petabytes of data), Hive’s reliance on the Hive Metastore and its approach to partitions leads to bottlenecks—especially with S3 object stores. Iceberg and Delta Lake were designed to efficiently manage metadata at this scale and reduce performance issues.

    
https://chatgpt.com/share/6835fe6f-3d78-800d-ab85-8f0372c843c7