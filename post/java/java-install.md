---
title: install java
date: 2018-09-27
---
# install java
    JRE： Java Runtime Environment
    JDK：Java Development Kit 
    JDK = JRE(JVM)+javatool(javac+java+jar+javap+javadoc+...)

版本：

    java se 标准版
    java ee 企业版
    java ME 微型版：嵌入式、移动设备
    java -version

## jdk
jdk include jre(java run-time environment)

    sudo yum install java-1.8.0-openjdk -y
    sudo yum install java-1.8.0-openjdk-devel -y
    sudo yum install java-devel ;# it will install java-1.8.0-openjdk and lib
    # or download http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html

    cat <<-MM >> ~/.profile
    export JAVA_HOME=/usr/local/jdk/jdk1.8.0_73
    export CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar
    export PATH=$JAVA_HOME/bin:$PATH
    MM

### Mac jdk

    # clear java 1.7: https://www.java.com/zh_CN/download/help/mac_uninstall_java.xml
    $ rm -rf  ~/Library/Application\ Support/Oracle
    $ sudo rm -rf  /Library/Application\ Support/Oracle
    $ sudo rm -fr /Library/PreferencePanes/JavaControlPanel.prefPane
    $ sudo rm -fr /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin
    $ du -sh /System/Library/Java
    60K	/System/Library/Java
    !!!!请勿尝试通过从 /usr/bin 删除 Java 工具来卸载 Java。此目录是系统软件的一部分
    $ cd /Library/Java/JavaVirtualMachines/
    $ sudo mv jdk1.7.0_45.jdk  jdk1.7.0_45.jdk.backup

install jdk12

    brew  cask install java

# ENV

## java-home
You may need to set JAVA_HOME, JRE_HOME, PATH:

  export JAVA_HOME="$(/usr/libexec/java_home -v 1.7)"
  export JAVA_HOME="$(/usr/libexec/java_home -v 12)"
  ➜ > ~ /usr/libexec/java_home -v 1.7
  /Library/Java/JavaVirtualMachines/jdk1.7.0_45.jdk/Contents/Home

  export JRE_HOME=$JAVA_HOME/jre
  export PATH=$PATH:$JRE_HOME/bin
  export CLASSPATH='.;./jdk1.7.0\lib\dt.jar'

### for mac JAVA_HOME

    java -version
    export JAVA_HOME="$(/usr/libexec/java_home -v 1.7)"
        /Library/Java/JavaVirtualMachines/jdk1.7.0_45.jdk/Contents/Home
        JAVA_HOME=/Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/HOME
        /usr/libexec/java_home ;When you install the XCode command line tools

## which javac

  ➜ > php-lib git:(master) ✗l `which javac`
  lrwxr-xr-x  1 root  wheel    75B Dec 11  2015 /usr/bin/javac -> /System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/javac
  /System/Library/Frameworks/JavaVM.framework/Versions/A/Commands/javac
  ➜ > php-lib git:(master) ✗l `which java`
  lrwxr-xr-x  1 root  wheel    74B Dec 11  2015 /usr/bin/java ->
  /System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java

# compile
注意文件大小写

    # build HelloWorld.class (大小写、java后缀不可省略)
    javac HelloWorld.java

不用注意文件大小写

    # 类似go run (.java不可省略)
    java HelloWorld.java
    java helloworld.java

    # run class(不要带.class)
    java HelloWorld
    java helloworld

## set classpath

    java -cp "Test.jar:lib/*" my.package.MainClass

## compile example

	# wget https://raw.githubusercontent.com/stevenholder/PHP-Java-AES-Encrypt/master/security.java -O Security.java
    $ wget http://www.java2s.com/Code/JarDownload/commons-codec/commons-codec-1.7.jar.zip
    $ unzip -x commons-codec-1.7.jar.zip

	$ javac -classpath 'commons-codec-1.7.jar' Security.java
	# javac -classpath 'commons-codec-1.7.jar' path/to/Security.java

    # 解出jar包才能java 运行, 包括打包
    $ unzip -x commons-codec-1.7.jar
    $ #rm commons-codec-1.7.jar
    $ java Security; # 不要跟.class
        Exception in thread "main" java.lang.NoClassDefFoundError: org/apache/commons/codec/binary/Base64
    	at Security.encrypt(Security.java:17)
    	at Security.main(Security.java:36)

note:
1. 类名必须文件名一致，且大小写相同
2. 必须有main 入口

## import
对于这样的代码

    import org.apache.commons.codec.binary.Base64;
    import org.apache.commons.codec.binary.*;

需要的jar

    Archive: unzip -t commons-codec-1.7.jar
    testing: META-INF/                OK
    testing: META-INF/MANIFEST.MF     OK
    testing: org/apache/commons/codec/binary/Base64.class   OK

## execute
要先解jar, 打包也一样, 否则会报错 比如:

    $ java xxx
    Exception in thread "main" java.lang.NoClassDefFoundError: org/apache/commons/codec/binary/Base64
    	at Aes.encrypt(Aes.java:17)
    	at Aes.main(Aes.java:36)
    Caused by: java.lang.ClassNotFoundException: org.apache.commons.codec.binary.Base64

# jar

## package jar

    jar cvf ip.jar com/cn/lbs/IPSeeker.class com/cn/lbs/SplitAddress.class

把一个文件夹下面所有的class文件打成jar包:

    jar cvf ip.jar *

## run jar

    java -jar xxx.jar
    java className

### no main manifest attribute
you need to jar a file called `META-INF/MANIFEST.MF`, the file itself should have (at least) this one liner:

    $ cat META-INF/MANIFEST.MF; Class-Path 指定加载的jar 的路径, 不要将jar 打到包里, 这是没有用的
    Main-Class: com.mypackage.MyClass
    Class-Path: lib/one.jar lib/two.jar

Where `com.mypackage.MyClass` is the class holding the `public static void main(String[] args)` entry point.

Note that there are several ways to get this done either with the CLI, Maven or Ant:

For *CLI*, the following command will do: (tks @dvvrt)

    jar cmvf META-INF/MANIFEST.MF <new-jar-filename>.jar  <files to include>

For *Maven*, something like the following snippet should do the trick. Note that this is only the plugin definition, not the full pom.xml:

    <build>
     <plugins>
       <plugin>
         <!-- Build an executable JAR -->
         <groupId>org.apache.maven.plugins</groupId>
         <artifactId>maven-jar-plugin</artifactId>
         <version>2.4</version>
         <configuration>
           <archive>
             <manifest>
               <addClasspath>true</addClasspath>
               <classpathPrefix>lib/</classpathPrefix>
               <mainClass>com.mypackage.MyClass</mainClass>
             </manifest>
           </archive>
         </configuration>
       </plugin>
     </plugins>
    </build>

For *Ant*, the snippet below should help:

    <jar destfile="build/main/checksites.jar">
     <fileset dir="build/main/classes"/>
     <zipfileset includes="**/*.class" src="lib/main/some.jar"/>
     <manifest>
       <attribute name="Main-Class" value="com.acme.checksites.Main"/>
     </manifest>
    </jar>