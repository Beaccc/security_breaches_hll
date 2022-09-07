module Api
  class AttackController < ApplicationController
      
    def initialize(sizeA)
      @sizeA =  sizeA.to_i
      # # # # # # # # # # # # # # # # # # # # # # # 

      @attack_vector1 = [] #Attack Vector
      @attack_vector2 = [] #Attack Vector
      @attack_vector3 = [] #Attack Vector
      @attack_vector4 = [] #Attack Vector
      @attack_vector5 = [] #Attack Vector
      @attack_vector6 = [] #Attack Vector
      @attack_vector7 = [] #Attack Vector
      @attack_vector8 = [] #Attack Vector
      @attack_vector9 = [] #Attack Vector
      @attack_vector10 = [] #Attack Vector

      @nested_array_short = [@attack_vector1,@attack_vector2,@attack_vector3,@attack_vector4,@attack_vector5]

      @nested_array = [@attack_vector1,@attack_vector2,@attack_vector3,@attack_vector4,@attack_vector5,
        @attack_vector6,@attack_vector7,@attack_vector8,@attack_vector9,@attack_vector10]

    end
  
    def reset
      #Reset the database to perform a new experiment
      Conversion.delete_all
      ConversionFiltered.delete_all
      AttackVector.delete_all
      AttackVectorFiltered.delete_all
      ActiveRecord::Base.connection.execute("Truncate table conversions ")
      ActiveRecord::Base.connection.execute("Truncate table conversion_filtereds ")
      ActiveRecord::Base.connection.execute("Truncate table attack_vectors ")
      ActiveRecord::Base.connection.execute("Truncate table attack_vector_filtereds ")
    end
  

     def creation_phase
      File.write("attack-steps.txt", "... Creating the #{@nested_array.length} attack vectors  with a size of #{@sizeA}... \n\n")
      #Create 10 HLL (attack vectors) with the numbers that don't increment the cardinality

      @contador = 1
      @nested_array.each do |attack_vector|

        Conversion.delete_all
        ActiveRecord::Base.connection.execute("Truncate table conversions ")
    
        File.write("attack-steps.txt", "Attack vector: #{@contador} \n", mode: 'a')

        start = Time.now #start counting time

        while attack_vector.length < @sizeA
  
          aux = Random.rand(0...10000000)

          c_ant = Utils::PrestoDb.new.get_cardinality()
          Conversion.create(element: aux) 
          c_new = Utils::PrestoDb.new.get_cardinality()

          if c_new == c_ant
            attack_vector.push(aux)
            puts "********************************************************************************************"
            puts "#{attack_vector.length}"
          end
          @contador = contador + 1
        end

        finish = Time.now
        diff = finish - start
        File.write("attack-steps.txt", "Array created, Nº elements: #{attack_vector.length}\n", mode: 'a')
        File.write("attack-steps.txt", "Execution time to create the vector #{attack_vector[0]}: #{diff} s\n\n", mode: 'a')

      end 

      #Now in this point we have 10 attack vectors with X elements that don't increment the cardinality

    end


    #Lets join these 10 attack vectors in an empty HLL
    def joining_phase
      ConversionFiltered.delete_all
      ActiveRecord::Base.connection.execute("Truncate table conversion_filtereds ")

      File.write("attack-steps.txt", "... Test phase ...\n\n", mode: 'a')

      start = Time.now #start counting time

      @nested_array.each do |attack_vector|
        attack_vector.each do |c|
          ConversionFiltered.create(element: c) #Insert each element of the attack in conversion filtered
        end
      end

      finish = Time.now
      diff = finish - start

      File.write("attack-steps.txt", "Joining all the elements of the diferent attack vectors in an empty HLL\n", mode: 'a')
      File.write("attack-steps.txt", "Execution time: #{diff} s\n\n", mode: 'a')
      File.write("attack-steps.txt", "... Calculating cardinality ...\n\n", mode: 'a')
      File.write("attack-steps.txt", "REAL SIZE:  #{Utils::PrestoDb.new.get_rows_conversion_filtereds()} \n", mode: 'a')
      File.write("attack-steps.txt", "APPROX_DISTINCT ESTIMATION: #{Utils::PrestoDb.new.get_cardinality_filtered()} \n", mode: 'a')   
    end

    #Now we shuffle the elements of the HLL and filter the elements and filter the elements, rechecking those that do not
    #really increase the cardinality and keeping only those elements
    def filter_1
      File.write("attack-steps.txt", "\n... Mixing and filtering phase ...\n\n", mode: 'a')

      Conversion.delete_all
      AttackVectorFiltered.delete_all
      ActiveRecord::Base.connection.execute("Truncate table conversions ")
      ActiveRecord::Base.connection.execute("Truncate table attack_vector_filtereds ")

      @array = [] 
      @array = Utils::PrestoDb.new.get_elements(@array)

      File.write("attack-steps.txt", "Array has #{@array.length} elements ", mode: 'a')
      File.write("attack-steps.txt", "\n\n... Shuffling elements ... \n\n", mode: 'a')
      @array.shuffle()  #mix elements

      File.write("attack-steps.txt", "... Filtering elements ... \n", mode: 'a')

      contador = 0
      contador2 = 0
      @array.each do |x|
        puts "#{contador}"
        c_ant = Utils::PrestoDb.new.get_cardinality()
        Conversion.create(element: x) 
        c_new = Utils::PrestoDb.new.get_cardinality()
        if c_new == c_ant
          contador2 = contador2 +1 
          puts "*************************************"
          puts "Se han insertado #{contador2} elementos"
          AttackVectorFiltered.create(element: x) 
        end
        contador = contador + 1
      end
      File.write("attack-steps.txt", "REAL SIZE:  #{Utils::PrestoDb.new.get_rows_attack_vector_filtereds()} \n", mode: 'a')
      File.write("attack-steps.txt", "APPROX_DISTINCT ESTIMATION: #{Utils::PrestoDb.new.get_cardinality_attack_vector_filtereds()} \n", mode: 'a')

    end

    #Second step filter, rechecking those that don't increase cardinality and keeping only those
    def filter_2
      File.write("attack-steps.txt", "\n\n... Filtering phase 2 ...\n\n", mode: 'a')

      Conversion.delete_all
      AttackVector.delete_all
      ActiveRecord::Base.connection.execute("Truncate table conversions ")
      ActiveRecord::Base.connection.execute("Truncate table attack_vectors ")

      @array2 = [] 
      @array2 = Utils::PrestoDb.new.get_elements_fase2(@array2) #get elements obtained in filtering phase 1
      puts "#{@array2.length}"

      File.write("attack-steps.txt", "Array has #{@array2.length} elements ", mode: 'a')
      File.write("attack-steps.txt", "\n\n... Shuffling elements ... \n\n", mode: 'a')
      @array2.shuffle()  #mix elements


      contador = 0
      contador2 = 0
      @array2.each do |x|
        puts "#{contador}"
        c_ant = Utils::PrestoDb.new.get_cardinality()
        Conversion.create(element: x) 
        c_new = Utils::PrestoDb.new.get_cardinality()

        if c_new == c_ant
          contador2 = contador2 +1 
          puts "*************************************"
          puts "Se han insertado #{contador2} elementos"
          AttackVector.create(element: x) 
        end
        contador = contador + 1
      end
      File.write("attack-steps.txt", "REAL SIZE:  #{Utils::PrestoDb.new.get_rows_attack_vector_fase2()} \n", mode: 'a')
      File.write("attack-steps.txt", "APPROX_DISTINCT ESTIMATION: #{Utils::PrestoDb.new.get_cardinality_attack_vector_fase2()} \n", mode: 'a')
    end

    #Third step filter, rechecking those that don't increase cardinality and keeping only those
    def filter_3
      File.write("attack-steps.txt", "\n\n... Filtering phase 3 ...\n\n", mode: 'a')

      Conversion.delete_all
      AttackVectorFiltered.delete_all
      ActiveRecord::Base.connection.execute("Truncate table conversions ")
      ActiveRecord::Base.connection.execute("Truncate table attack_vector_filtereds ")

      @array3 = [] 
      @array3 = Utils::PrestoDb.new.get_elements_fase3(@array3) #get elements obtained in filtering phase 2
      puts "#{@array3.length}"

      File.write("attack-steps.txt", "Array has #{@array3.length} elements ", mode: 'a')
      File.write("attack-steps.txt", "\n\n... Shuffling elements ... \n\n", mode: 'a')
      @array3.shuffle()  #mix elements
    
      contador = 0
      contador2 = 0
      @array3.each do |x|
        puts "#{contador}"
        c_ant = Utils::PrestoDb.new.get_cardinality()
        Conversion.create(element: x) 
        c_new = Utils::PrestoDb.new.get_cardinality()

        if c_new == c_ant
          contador2 = contador2 +1 
          puts "*************************************"
          puts "Se han insertado #{contador2} elementos"
          AttackVectorFiltered.create(element: x) 
        end
        contador = contador + 1
      end
      File.write("attack-steps.txt", "REAL SIZE:  #{Utils::PrestoDb.new.get_rows_attack_vector_filtereds()} \n", mode: 'a')
      File.write("attack-steps.txt", "APPROX_DISTINCT ESTIMATION: #{Utils::PrestoDb.new.get_cardinality_attack_vector_filtereds()} \n", mode: 'a')
    end

    #Execute all the phases of the attack after resetting the database
    def all
      reset
      creation_phase
      joining_phase
      filter_1
      filter_2
      filter_3
    end

  end
end