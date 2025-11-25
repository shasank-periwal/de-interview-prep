- https://github.com/karanpratapsingh/system-design#whatsapp
- https://github.com/karanpratapsingh/system-design#twitter
- https://github.com/karanpratapsingh/system-design#netflix
- https://github.com/karanpratapsingh/system-design#uber
- https://www.enjoyalgorithms.com/blog/design-typeahead-system
- https://www.nexsoftsys.com/articles/how-to-design-backend-system-of-an-online-hotel-booking-app-using-java.html
- https://systemdesignprimer.com/dropbox-system-design/
- https://www.enjoyalgorithms.com/blog/web-crawler
- https://www.educative.io/courses/grokking-the-system-design-interview/system-design-tinyurl

1. [Latency vs Throughput](https://aws.amazon.com/compare/the-difference-between-throughput-and-latency/)
2. [CAP Theorem](https://www.bmc.com/blogs/cap-theorem/)
3. [ACID Transactions](https://redis.io/glossary/acid-transactions/)
4. [Consistent Hashing](https://arpitbhayani.me/blogs/consistent-hashing/): Solves the problem of increasing partition in load balancing by not disturbing the flow.
5. [Rate Limiting](https://www.imperva.com/learn/application-security/rate-limiting/)
6. [Microservices Architecture](https://medium.com/hashmapinc/the-what-why-and-how-of-a-microservices-architecture-4179579423a9): single responsibility principle which states “gather together those things that change for the same reason, and separate those things that change for different reasons
7. [API Design](https://blog.wahab2.com/api-architecture-best-practices-for-designing-rest-apis-bf907025f5f)
8. [Strong vs Eventual Consistency](https://hackernoon.com/eventual-vs-strong-consistency-in-distributed-databases-282fdad37cf7)
9. [Synchronous vs asynchronous communications](https://www.techtarget.com/searchapparchitecture/tip/Synchronous-vs-asynchronous-communication-The-differences)
10. [REST vs RPC](https://aws.amazon.com/compare/the-difference-between-rpc-and-rest/)
    - REST- Representational State Transfer
        - path parameter: `/books/id`
        - query parameter: `/books?limit=20&tags=fiction`
11. [Batch Processing vs Stream Processing](https://atlan.com/batch-processing-vs-stream-processing/)
12. [Fault Tolerance](https://www.cockroachlabs.com/blog/what-is-fault-tolerance/)
13. [Consensus Algorithms](https://medium.com/@sourabhatta1819/consensus-in-distributed-system-ac79f8ba2b8c)
14. [Gossip Protocol](https://highscalability.com/gossip-protocol-explained/)
15. [Serverless Architecture](https://www.datadoghq.com/knowledge-center/serverless-architecture/)
16. [Service Discovery](https://www.f5.com/company/blog/nginx/service-discovery-in-a-microservices-architecture)
17. [Disaster Recovery](https://cloud.google.com/learn/what-is-disaster-recovery)
18. [Distributed Tracing](https://www.dynatrace.com/news/blog/what-is-distributed-tracing/)
19. [Horizontal vs Vertical Scaling](https://www.spiceworks.com/tech/cloud/articles/horizontal-vs-vertical-cloud-scaling/)
20. [Content Delivery Network (CDN)](https://www.cloudflare.com/learning/cdn/what-is-a-cdn/)
21. [Domain Name System (DNS)](https://www.cloudflare.com/learning/dns/what-is-dns/)
22. [Caching](https://medium.com/must-know-computer-science/system-design-caching-acbd1b02ca01)
    - Cache Aside Strategy/Pattern(heavy reads): Server is connected to database and cache individually.
    - Read Through Strategy/Pattern(heavy writes): Cache sits between server and database.
    - Write Through Strategy/Pattern: Cache sits between server and database.
    - Write Around Strategy/Pattern(mix): Cache sits between server and database. Server writes to database directly and reads from cache.
    - Write Back Strategy/Pattern: Cache sits between server and database. Server writes to cache, cache stores all writes and sends a batch to the database.
23. [Distributed Caching](https://redis.io/glossary/distributed-caching/)
24. [Load Balancing](https://aws.amazon.com/what-is/load-balancing/)
25. [SQL vs NoSQL](https://www.integrate.io/blog/the-sql-vs-nosql-difference/)
26. [Database Index](https://www.progress.com/tutorials/odbc/using-indexes)
27. [Consistency Patterns](https://systemdesign.one/consistency-patterns/)
28. [HeartBeat](https://martinfowler.com/articles/patterns-of-distributed-systems/heartbeat.html)
29. [Circuit Breaker](https://medium.com/geekculture/design-patterns-for-microservices-circuit-breaker-pattern-276249ffab33)
30. [Idempotency](https://blog.dreamfactory.com/what-is-idempotency)
31. [Database Scaling](https://thenewstack.io/techniques-for-scaling-applications-with-a-database/)
32. [Data Replication](https://redis.io/blog/what-is-data-replication/)
33. [Data Redundancy](https://www.egnyte.com/guides/governance/data-redundancy)
34. [Database Sharding](https://www.mongodb.com/resources/products/capabilities/database-sharding-explained)
35. [Microservices Guidelines](https://newsletter.systemdesign.one/p/netflix-microservices)
36. [Failover]()
37. [Proxy Server](https://www.fortinet.com/resources/cyberglossary/proxy-server)
    - Forward Proxy - Hides client(s) from server and gives one way of communication.
    - Reverse Proxy - Hides server(s) from client and gives one way of communication. 
38. [Message Queues](https://medium.com/must-know-computer-science/system-design-message-queues-245612428a22)
39. [WebSockets](https://www.pubnub.com/guides/websockets/)
40. [Bloom Filters](https://www.enjoyalgorithms.com/blog/bloom-filter)
41. [API Gateway](https://www.f5.com/glossary/api-gateway)
42. [Distributed Locking](https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html)
43. [Checksum](https://www.lifewire.com/what-does-checksum-mean-2625825)

Application/Service perform certain tasks.
Oauth2



How does Redis store?

Fault is the cause; Failure is the effect.

Vertical Partitioning - Breaking up columns to store in different databases/server.