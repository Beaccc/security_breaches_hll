require 'presto-client'
module Utils
  class PrestoDb 
    def initialize
      # create a client object:
      @client = Presto::Client.new(
        server: "localhost:8010",   # required option
        ss: {verify: false},
        catalog: "mysql",
        schema: "test",
        user: "root",
        language: "English"
      )
    end

    def get_cardinality()
      columns, rows = @client.run("select approx_distinct(element) from conversions")
      rows[0][0]
    end

    def get_cardinality_filtered()
      columns, rows = @client.run("select approx_distinct(element) from conversion_filtereds")
      rows[0][0]
    end

    def random_suffle_attack_vector(array)
      ActiveRecord::Base.connection.execute("Truncate table attack_vector_filtereds ")
      array.each do |x|
        @client.run("insert into attack_vector_filtereds (element) values (#{x})")
      end
      #@client.run("insert into attack_vector_filtereds (element)  values Api::AttackController.new(10,0)array")
    end

    def get_elements(array)
      columns, rows =  @client.run("select element from conversion_filtereds")
      rows.each do |x|
        array.push(x[0])
      end
      array 
    end 

    def random_shuffling(database)
        ActiveRecord::Base.connection.execute("Truncate table summary_conversions ")
        @client.run("insert into summary_conversions select cast(approx_set(number) as varbinary) as conversion_hll_sketch from #{database} group by number order by RAND()")
        columns, rows = @client.run("select cardinality(merge(cast(hll as HyperLogLog))) as daily_conversions from summary_conversions")
        #Return cardinality
        puts "Cardinality for random_shuffling: #{rows}"
    end

    def get_rows_conversion_filtereds()
      columns, rows = @client.run("select count(element) from  conversion_filtereds")
      rows[0][0]
    end

    def get_rows_attack_vector_filtereds()
      columns, rows = @client.run("select count(element) from attack_vector_filtereds")
      rows[0][0]
    end

    def get_cardinality_attack_vector_filtereds()
      columns, rows = @client.run("select approx_distinct(element) from attack_vector_filtereds")
      rows[0][0]
    end

    def get_elements_fase2(array)
      columns, rows =  @client.run("select element from attack_vector_filtereds")
      rows.each do |x|
        array.push(x[0])
      end
      array 
    end 

    def get_rows_attack_vector_fase2()
      columns, rows = @client.run("select count(element) from attack_vectors")
      rows[0][0]
    end

    def get_cardinality_attack_vector_fase2()
      columns, rows = @client.run("select approx_distinct(element) from attack_vectors")
      rows[0][0]
    end

    def get_elements_fase3(array)
      columns, rows =  @client.run("select element from attack_vectors")
      rows.each do |x|
        array.push(x[0])
      end
      array 
    end 

  end
end