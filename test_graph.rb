#!/usr/bin/ruby

# Graph class manages nodes, edges and their relations
#
# Attributes:
#   @nodes - Hash that maps a (unique) element to the node that 
#               contains the element.
#   @edges - Hash that takes in a Node element as input
#               and returns a list of Edges corresponding
#               to that Node. Return of 'nil' on access
#               indicates the lack of a corresponding Node key.
#
# Implementation Assumptions: 
#   -No repeated directional edges (backwards direction is
#       be treated as a new edge)
#   -Edges do not point from a node to itself
#
# Notes: Repeated nodes (nodes that have the same element attribute)
#       are expected and handled by returning the node first declared 
#       for specific element to keep consistent node addresses in memory

class Graph
    def initialize()
        @nodes = {}
        @nodes.default = nil

        @edges = {} 
        @edges.default = nil
    end

    # Node setter (treated as getter if node already exists)
    # Input: One element, whose type varies by context of the 
    #           input text data. 
    # Summary: Creates and adds new node to our graph's node list 
    #           and initializes it's corresponding adjacency
    #           list to commence edge pushing. If the node already
    #           exists in our node list it returns the node.
    # Note: It also acts as a getter in the case of an existing node,
    #           in which case the node with the desired element
    #           is returned.
    # Return: Node created using the input element
    def add_node(elt)
        if new_node = get_node(elt)
            return new_node 
        end

        new_node = Node.new(elt)
        @nodes[elt] = new_node
        @edges[new_node] = []   #initialize array for us to push adjacent Edges
        new_node
    end

    # Edge setter
    # Input: Two node objects and an optional integer for 
    #           weight (defaulted to 1).
    # Summary: Creates hash mapping between 'from' node and
    #           an edge initialized using the three
    #           parameters.
    # Return: Edge created using respective parameters
    def add_edge(from,to,weight = 1)
        new_edge = Edge.new(from,to,weight)
        (@edges[from]).push(new_edge)

        new_edge
    end

    # Get corresponding node by it's element
    def get_node(elt)
        @nodes[elt]
    end

    # Getter for respective input node's Edge list
    def get_node_edges(node)
        @edges[node]
    end

    # Node list getter
    def get_all_nodes()
        @nodes.values
    end

    # Method for finding length of a given path (Problems 1-5)
    # Input: Elements of the desired node path
    def path_length(node_path)
        dist = 0
        print node_path[0..node_path.size-2].join
        from = get_node(node_path.shift)
        for elt in node_path[0..node_path.size-2]  # Ignores the '\n' at line's end
            if to = get_node(node_path.shift)
               for edge in get_node_edges(from) 
                   if edge.to_node == to
                       dist += edge.get_weight
                       from = to  # Set from for the next iteration
                       break
                   end
               end
               if from != to  # No connecting edge exists
                   puts " is NO SUCH ROUTE"
                   return
               end
            else
                puts " is NO SUCH ROUTE"
                return
            end
        end
        puts " has distance " + dist.to_s
    end

    # Function num_trips uses recursion on the stack to navigate 
    #   every path in the graph and sum each valid path's
    #   return of 1 and invalid path's 0 otherwise.
    # Input: 
    #   -Start and Finish: used to access respective node.
    #   -Steps: indicates how much valid traversal is left
    #   -Use_weight: used to identify whether we are treating
    #       each edge as a single unit or if we're using it's weight
    #       in our travel calculation
    #   -First_call: avoids counting a single node as a path to itself
    #                   on first call.
    #                   
    # Notes: Method for solving #6,7,10 involved Depth First Search. 
    #   The if/else statements used to handle
    #   details unique to each problem, but as the process is
    #   similar, they are used in the same function.
    #
    def num_trips(start,finish,steps,use_weight = false,first_call = false)
        count = 0
        if !use_weight
            if steps == 0
                if start == finish then return 1 else return 0 end
            end
        else
            if steps <= 0 then return 0
            elsif start == finish and steps > 0 and !first_call
                count = count + 1  
            end
        end

        start_node = get_node(start)

        for edge in get_node_edges(start_node)
            curr_char = edge.to_node.get_elt

            # Edge weight considered using use_weight variable.
            # We treat an edge as unit distance 1 otherwise.
            next_steps = (use_weight) ? steps-edge.get_weight : steps-1 

            count += num_trips(curr_char,finish,next_steps,use_weight)
        end

        return count
    end

    # Method shortest_path uses weighted values 
    #    it's DFS search, keeping each node's smallest path
    #    from the start node as a key to determine it's priority.
    def shortest_path(start,finish)
        prev = {}
        node_dist = {}

        for node in get_all_nodes
            if node.get_elt == start then next end
            prev[node] = nil
            node_dist[node.get_elt] = 1/0.0 #starting value of infinity
        end

        node_dist[start] = 0

        pq = PriorityQueue.new(node_dist)
        puts "Starting heap:"
        print pq.get_heap
        puts
        puts

        while !pq.is_empty
            curr = pq.get_top

            puts "Heap at start of loop"
            print pq.get_heap
            puts
            puts

            puts "Iterating through edges of element " + curr + ": "
            for edge in get_node_edges(get_node(curr))
                puts "    Edge:("+curr+","+edge.to_node.get_elt+")"
                next_elt = edge.to_node.get_elt
                print "    "+pq.get_priority(next_elt).to_s + " > " 
                puts pq.get_priority(curr).to_s + " + " + edge.get_weight.to_s
                
                if pq.get_priority(next_elt) > pq.get_priority(curr) + edge.get_weight
                    pq.update_priority(next_elt,pq.get_priority(curr) + edge.get_weight)
                    prev[get_node(next_elt)] = get_node(curr)

                    print "    Heap after update: "
                    print pq.get_heap
                    puts
                    puts
                end
            end
        end
        path = finish
        puts prev
#        while path = prev[path]
#            puts "previous of " + path[0] + ": " + prev[path][0]
#        end
    end
end

# The Node class acts as a container for the elements
#   our graph is made of.
class Node
    def initialize(elt)
        @elt = elt
    end

    # element getter
    def get_elt()
        @elt
    end
end

# The Edge class used to brand a directed
#   path between two nodes. This path is quantified 
#   by the Edge's weight attribute.
class Edge
    def initialize(from,to,weight=1)
        @from = from
        @to = to
        @weight = weight
    end

    #getter methods proceeding
    def from_node()
        @from
    end

    def to_node()
        @to
    end

    def get_weight()
        @weight
    end
end

# Priority Queue implemented using a min-heap structure. 
# Notes: The heap has it's root at 1 (index 0 holds Null) as it finding
#           parent nodes is made much easier when it is located at the floor
#           of the current node's index divided by 2.
#
class PriorityQueue
    # Input: Hash of elements and their priorities
    def initialize(elt_priority)
        @heap = [nil]         # Create offset of 1 for easy tree navigation
        @index_of = {}        # Instant access to index for update_priority
        @size = 0
        @priority = elt_priority #Hash from element to priority
        for elt in @priority.keys
            insert(elt)
        end
    end

    def get_heap()
        @heap
    end

    def get_priority(elt)
        index = @index_of[elt] 
        print "          index of element " + elt +":" + index.to_s
        puts
        print "                heap:"
        print @heap
        puts
        print "                priority:"
        print @priority
        puts
        elt_priority = @priority[elt]
        return elt_priority
    end

    def is_empty()
        if @size == 0
            return true
        else
            return false
        end
    end

    # Input: Element-Priority pair
    def insert(elt)
        @heap.push(elt) 
        @size = @size + 1
        @index_of[elt] = @size
        trickle_up(elt)
    end

    def get_top()
        if @size == 0
            return nil 
        end

        old_head = @heap[1]
        @index_of[old_head] = nil 

        new_head = @heap.pop
        @heap[1] = new_head
        @index_of[new_head] = 1

        @size = @size - 1

        trickle_down(new_head)
        return old_head
    end

    def update_priority(elt,new_priority)
        index = @index_of[elt]
        @priority[@heap[index]] = new_priority
        puts "            updating priority of " + elt
        puts "            heap:"
for el in get_heap[1..@size]
    print "                "
    puts el.to_s + " with priority " + el.to_s
end

        # We maintain heap property using functions tailored to do so
        puts
        print "            before trickle_up of "
        puts @heap[index].to_s + " " + @priority[@heap[index]].to_s

        trickle_up(@heap[index])

        print "            after trickle up - before trickle_down "
        puts @heap[index].to_s + " " + @priority[@heap[index]].to_s

        trickle_down(@heap[index])

        print "            after trickle_down "
        puts @heap[index].to_s + " " + @priority[@heap[index]].to_s
    end

    # Input: Element-Priority pair
    # Summary: Swaps input node with parent if it has smaller priority than it.
    # Repeats call on itself using the same input pair until the 
    # heap property is restored.
    # Notes: It swaps with the leftmost child in the case of children 
    #       with equal priority (that is also greater than our pair's
    #       priority).
    def trickle_up(elt)
        parent_index = @index_of[elt]/2
        while @heap[parent_index]
            if @priority[elt] < @priority[@heap[parent_index]]
                print "                swapping "
                puts elt + " and " + @heap[parent_index]
                swap(elt,@heap[parent_index])
                parent_index = parent_index/2
            else
                break
            end
        end
    end

    # Input: Element-Priority pair
    # Summary: Swaps input node with child of greatest priority if there is any.
    # Repeats call on itself using the same input pair until the heap
    # property is restored.
    # Notes: It swaps with the leftmost child in the case of children 
    #       with equal priority (that is also greater than our pair's
    #       priority).
    def trickle_down(elt)
        l_index = @index_of[elt]*2
        r_index = @index_of[elt]*2+1
        puts @size
        
        if r_index > @size
            if l_index > @size
                return
            else
                if @priority[@heap[l_index]] < @priority[elt]
                    swap(@heap[l_index],elt)
                    trickle_down(elt)
                end
            end
        elsif @priority[@heap[l_index]] - @priority[@heap[r_index]] >= 0
            if @priority[@heap[l_index]] < @priority[elt]
                swap(@heap[l_index],elt)
                trickle_down(elt)
            end
        else
            if @priority[@heap[r_index]] < @priority[elt]
                swap(@heap[r_index],elt)
                trickle_down(elt)
            end
        end
    end

    # Input: Pair of elements we intend to swap in the heap
    def swap(elt1,elt2)
        index1 = @index_of[elt1]
        index2 = @index_of[elt2]

        @index_of[elt2] = index1
        @index_of[elt1] = index2

        @heap[index2] = elt1
        @heap[index1] = elt2
    end
end
