#!/usr/bin/ruby
#Author: Gylmar Moreno
#Date: 2/5/14
#Email: g2moreno@ucsd.edu

require './graph.rb'
require './priorityQ.rb'

graph_file = ARGV[0]
command_file = ARGV[1]

g = Graph.new()
f = File.open(graph_file,'r')

# Build graph data structure using file contents
while(line = f.gets)
    from = g.add_node(line[0])
    to = g.add_node(line[1])
    weight = line[2].to_i

    edge = g.add_edge(from,to,weight)
end

f.close()


# The README contains instructions for properly setting up commands
# to use the graph functions.
f = File.open(command_file,'r')
while(line = f.gets)
    line = line.split(' ') 

    if line.size > 1
        if line[0].size > 1 or line[1].size > 1 or 
            line[0].class != String or line[1].class != String
            puts "Wrong input!"
            next
        end
        if line.size > 2
            if not val = Integer(line[2]) rescue nil
                puts "Need Fixnum value as 3rd argument!"
                next
            end
        end
    elsif line.size == 1
        if line[0].class != String
            puts "Wrong input!"
            next
        end
    else 
        puts "Error in input!"
        next
    end

    case line.size
    when 1
        print "Calling path_length(" + line[0] + "): " 
        puts g.path_length(line[0].split(''))
    when 2
        puts "Calling shortest_path(" + line[0] + "," + line[1] +"): " +
            g.shortest_path(line[0],line[1]).to_s
    when 3
        puts "Calling exact num_trips(" + line[0] + "," + line[1] + "," + 
            val.to_s + "): " + g.num_trips(line[0],line[1],val).to_s
    when 4
        if line[3] == "max"
            print "Calling max num_trips(" 
            print line[0] + "," + line[1] + "," + line[2] + "): " 

            total = 0
            for i in (1..val).to_a
                total = total + g.num_trips(line[0],line[1],i)
            end
            puts total.to_s
        elsif line[3] == "weighted"

            print "Calling weighted num_trips(" 
            print line[0] + "," + line[1] + "," + val.to_s + "): " 

            if line[0] == line[1]
                puts g.num_trips(line[0],line[1],val,true,true).to_s
            else
                puts g.num_trips(line[0],line[1],val,true).to_s
            end
        else
            puts "Only 'max' and 'weighted' accepted at last index!"
        end
    else 
        puts "Line is not valid input!"
    end
end

def print_sample_solutions(graph)
    puts "Output #1: " + graph.path_length(['A','B','C']).to_s
    puts "Output #2: " + graph.path_length(["A","D"]).to_s
    puts "Output #3: " + graph.path_length(["A","D","C"]).to_s
    puts "Output #4: " + graph.path_length(["A","E","B","C","D"]).to_s
    puts "Output #5: " + graph.path_length(["A","E","D"]).to_s
    puts "Output #6: " + (graph.num_trips("C","C",1) +
                            graph.num_trips("C","C",2) + 
                            graph.num_trips("C","C",3)).to_s
    puts "Output #7: " + graph.num_trips("A","C",4).to_s
    puts "Output #8: " + graph.shortest_path("A","C").to_s
    puts "Output #9: " + graph.shortest_path("B","B").to_s
    puts "Output #10: " + graph.num_trips("C","C",30,true,true).to_s
end

#print_sample_solutions(g)
