Coherence – Session Sharing between Applications Hosted on Different Application Servers / Hosted on Different WebLogic Domains:


Session state in Java Web application is associated with a single (user) browser session. Sometimes there will be a requirement where  the session data has to be shared by "Between Web applications within the EAR" / "Between Web Applications" / "Between EARs" / "Between EARs located in Different Weblogic Server Domains" / "Between EARs located in Different Application Servers".

In weblogic Server there is an option to share session between web applications present within the EAR. But some time there might be a requirement to share the session "Between Web Applications" / "Between EARs" / "Between EARs located in Different Weblogic Server Domains" / "Between EARs located in Different Application Servers". We can achieve this only with the help of caching tool.

Coherence is one of the most popular caching tools available. With help of coherence we will store sessions in a different JVM from where the application is running (application on application server). This session is shared by different JVMs (Different Domains/Different Application Servers etc).

Coherence*Web allows session data to be shared by different Web applications deployed in the same or different Web containers. To do so, you must correctly configure the Coherence*Web cookie context parameters and you must make the classes of objects stored in session attributes available to each Web application.

If you are using cookies to store session IDs (that is, you are not using URL rewriting), you must set the coherence-session-cookie-path context parameter to a common context path of all Web applications that share session data.

 For example, if you would like to share session data between two Web applications registered under the contexts paths /web/CoherenceCacheWeb_1 and  /web/CoherenceCacheWeb_2, you should set the coherence-session-cookie-path parameter to /web. On the other hand, if two Web applications are registered under the context paths /CoherenceCacheWeb_1 and /CoherenceCacheWeb_2, you should set the coherence-session-cookie-path parameter to /.
Scenario1: Session Sharing between two individual Webapplication:

Lets consider you have two webapplications

1) CoherenceCacheWeb_1.war
2) CoherenceCacheWeb_2.war

1) If you want both webapplication share the same session. You must set coherence-session-cookie-path context parameter to a common context path for all the webapplications. Instead of setting coherence-session-cookie-path you can set wls:session-descriptor in weblogic.xml.

For both the above webapplications, in the web.xml we should mention as shown below

   <context-param>
    <param-name>coherence-session-cookie-path</param-name>
    <param-value>/</param-value>
  </context-param>

(or)


For both the above webapplications, in the weblogic.xml we should mention as shown below

    <wls:session-descriptor>
        <wls:cookie-name>JSESSIONID</wls:cookie-name>
        <wls:cookie-path>/</wls:cookie-path>
    </wls:session-descriptor>

2) For both the above webapplications, in the web.xml we should mention as shown below

  <context-param>
    <param-name>coherence-scopecontroller-class</param-name>
    <param-value>com.tangosol.coherence.servlet.AbstractHttpSessionCollection$GlobalScopeController</param-value>
  </context-param>
3) If you want to configure the session to share data across the applications, you should also configure the coherence-scopecontroller-class context parameter across the applications to use global scope. Configure below in both CoherenceCacheWeb_1.war and CoherenceCacheWeb_2.war

  <context-param>
    <param-name>coherence-scopecontroller-class</param-name>
    <param-value>com.tangosol.coherence.servlet.AbstractHttpSessionCollection$GlobalScopeController</param-value>
  </context-param>

4) You should create web-cache-server.cmd in coherence_home\bin. Create a duplicate copy of cache-server.cmd and rename to web-cache-server.cmd.

Modify  "%java_exec% -server -showversion %java_opts% -cp "%coherence_home%\lib\coherence.jar" com.tangosol.net.DefaultCacheServer %1"

to

%java_exec% -server -showversion %java_opts% -cp "%coherence_home%\lib\coherence.jar;%coherence_home%\lib\coherence-web-spi.war"  -Dtangosol.coherence.management.remote=true -Dtangosol.coherence.cacheconfig=WEB-INF/classes/session-cache-config.xml -Dtangosol.coherence.distributed.localstorage=true -Dtangosol.coherence.session.localstorage=true com.tangosol.net.DefaultCacheServer %1

5)  Now run web-cache-server.cmd. If you getting the below exception during startup

 2012-08-09 15:42:18.535/2.987 Oracle Coherence GE 3.7.1.1 <Error> (thread=Cluste
r, member=n/a): This member could not join the cluster because of a configuratio
n mismatch between this member and the configuration being used by the rest of t
he cluster. This member specified a cluster name of "cluster:0xFCDB" which did n
ot match the name of the running cluster. This indicates that there are multiple
 clusters on this network attempting to use overlapping network configurations.
Rejected by Member(Id=1, Timestamp=2012-08-09 14:39:52.595, Address=10.177.113.2
53:8088, MachineId=8475, Location=site:,machine:blr2230328,process:31893, Role=W
eblogicServer).
2012-08-09 15:42:18.536/2.988 Oracle Coherence GE 3.7.1.1 <D5> (thread=Cluster,
member=n/a): Service Cluster left the cluster
2012-08-09 15:42:18.539/2.991 Oracle Coherence GE 3.7.1.1 <Error> (thread=main,
member=n/a): Error while starting cluster: java.lang.RuntimeException: Failed to
 start Service "Cluster" (ServiceState=SERVICE_STOPPED, STATE_JOINING)
        at com.tangosol.coherence.component.util.daemon.queueProcessor.Service.s
tart(Service.CDB:38)
        at com.tangosol.coherence.component.util.daemon.queueProcessor.service.G
rid.start(Grid.CDB:6)
        at com.tangosol.coherence.component.net.Cluster.onStart(Cluster.CDB:56)
        at com.tangosol.coherence.component.net.Cluster.start(Cluster.CDB:11)
        at com.tangosol.coherence.component.util.SafeCluster.startCluster(SafeCl
uster.CDB:3)
        at com.tangosol.coherence.component.util.SafeCluster.restartCluster(Safe
Cluster.CDB:10)

 Modify %java_exec% -server -showversion %java_opts% -cp "%coherence_home%\lib\coherence.jar;%coherence_home%\lib\coherence-web-spi.war"  -Dtangosol.coherence.management.remote=true -Dtangosol.coherence.cacheconfig=WEB-INF/classes/session-cache-config.xml -Dtangosol.coherence.distributed.localstorage=true -Dtangosol.coherence.session.localstorage=true com.tangosol.net.DefaultCacheServer %1

 to

%java_exec% -server -showversion %java_opts% -cp "%coherence_home%\lib\coherence.jar;%coherence_home%\lib\coherence-web-spi.war" -Dtangosol.coherence.cluster=cluster:0xFCDB -Dtangosol.coherence.clusterport=7777 -Dtangosol.coherence.management.remote=true -Dtangosol.coherence.cacheconfig=WEB-INF/classes/session-cache-config.xml -Dtangosol.coherence.distributed.localstorage=true -Dtangosol.coherence.session.localstorage=true com.tangosol.net.DefaultCacheServer %1

 The value of  -Dtangosol.coherence.cluster depends on the exception. Here the exception is "This member specified a cluster name of "cluster:0xFCDB"" and hence the system parameter is   -Dtangosol.coherence.cluster=cluster:0xFCDB and port -Dtangosol.coherence.clusterport=7777.

There is a patch for other wise you can use the above system properties as workaround.

6) Start weblogic server and deploy coherence-web-spi.war and active-cache-1.0.jar as shared libraries. Also refer these two libraries in weblogic.xml of both the applications.

7) Deploy CoherenceCacheWeb_1.war and CoherenceCacheWeb_2.war. 

8) Execute http://<hostname>:<port>/ CoherenceCacheWeb_1/TestServlet and http://<hostname>:<port>/ CoherenceCacheWeb_2/TestServlet. You will observe that session is shared between webapplications.

Scenario2: Session Sharing between EARs:

Configure same as above. Each webapplication present in each EAR.

Scenario3: Between EARs located in Different Weblogic Server Domains:

Configure same as scenario 1 after step 2 follow the below step also. 

1) If the Web applications that you would like to share session data are deployed on different Web containers running on different machines (that are not behind a common load balancer), you must also set the coherence-session-cookie-domain parameter to a domain shared by the machines. For example, if you would like to share session data between two Web applications running on server1.mydomain.com and server2.mydomain.com, you must set the coherence-session-cookie-domain parameter to .mydomain.com.

  <context-param>
    <param-name>coherence-session-cookie-domain</param-name>
    <param-value>.mydomain.com</param-value>
  </context-param>

Scenario4: Between EARs located in Different Application Servers:

Configure same as scenario 1 after step 2 follow the below step also. 

WebLogic Server adds a session affinity suffix to the cookie which is not part of the session ID stored in Coherence*Web.
The other application servers must remove the WebLogic session affinity suffix from the session cookie value for Coherence*Web to be able to retrieve the session from the Coherence cache.
To strip the WebLogic session affinity suffix from the session cookie, add the coherence-session-affinity-token context parameter to the web.xml file used in the other application servers. Set the parameter value to an exclamation point (!). The session affinity suffix will be removed from the session cookie when it is processed by the other application server.

<context-param>
      <param-name>coherence-session-affinity-token</param-name>
      <param-value>!</param-value>
</context-param>


To correctly serialize/deserialize objects stored in shared sessions, the classes of all objects stored in session attributes must be available to Web applications that share session data. For Web applications deployed on different containers, the classes may be placed in either the Web container or Web application classpath; however, for application deployed in the same Web container, the classes must be placed in the Web container classpath. This is due to the fact that most containers load each Web application using a separate ClassLoader.
