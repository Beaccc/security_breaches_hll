# README

# security_breaches_hll

Repository created to support my Master Thesis: Security Breaches on HyperLogLog (HLL) Data Sketch. In this project the security of Hyperloglog algorithm is tested trying to manipulate its estimates. An evasion attack has been carried out against the implementation of HLL in Presto.

##Versions:

Ruby 2.5.1 
Prest-Server-350
MySQL 8.0.30

## Installation:

###Dependencies
The first step is to install al the dependencies by executing:

```bash
bundle install
```

Then we have to set up the database and create the tables with:

```bash
rake db:create
```

```bash
rake db:migrate
```

### Presto
The next step would be to install Presto. It is advisable to go to the official webpage and follow the intallation guide: [PrestoDB webpage](https://prestodb.io/docs/current/installation.html).

### MySQL
A correct installation of mysql is required. You need an user and a password to acces to the service. Follow the installation guide: [MySQL installatino guide](https://dev.mysql.com/doc/mysql-installation-excerpt/8.0/en/)


Once all dependencies are satisfied the next step is to run it.


## Usage

Navigate to the directory in which you have just installed Presto/bin and start the server by executing:

```bash
./launcher start
```
```bash
./launcher run
```

For stopping the server you need to execute:

```bash
./launcher stop
```

Once the server is started, you should update the values in /lib/utils/presto.db with those you chose when configuring Presto.

```bash
 @client = Presto::Client.new(
        server: "localhost:8080",   
        ss: {verify: false},
        catalog: "mysql",           
        schema: "test",             
        user: "root",
        time_zone: "US/Pacific",
        language: "English"
      )
```

Next step is navigating to the main directory of the project and start the Rails console by executing:

```bash
rails c
```

Finally, run the attack by calling the controller:

```bash
Api::AttackController.new(targetCardinality/10).all
```
In the first phase the attack creates 10 attack vectors, which are joined in the second phase to  achieve the target cardinality. That is the reason why the input of the controller is the targetCardinality/10, because it would added up later. 

The results will be written to a text file called attack-steps.txt which will be located in the root directory of the project.
Note that if you choose a very high cardinality, the attack will take some time.
