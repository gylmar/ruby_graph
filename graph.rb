#!/usr/bin/ruby

require './priorityQ.rb'

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
        return new_edge
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

    # Input: Node path in the form of an element array.
    #
    # Summary: This is the method used for finding length of 
    #            a given path (Problems 1-5). It does so by checking
    #            the edges of the 'current' node and proceeding if
    #            it finds one that connects it with the next node
    #            in the list. 
    #          It will navigate the entire graph in the worst case.
    #
    # Output: Returns the cummulative weight of the traversed path.
    def path_length(node_path)
        dist = 0

        if node_path.size == 0
            return "NO SUCH ROUTE"
        end

        from = get_node(node_path.shift)
        for elt in node_path[0..node_path.size-1]
            if to = get_node(node_path.shift)
               for edge in get_node_edges(from) 
                   if edge.to_node == to
                       dist += edge.get_weight
                       from = to  # Set 'from' for the next iteration
                       break
                   end
               end
               if from != to  # No connecting edge exists
                   return "NO SUCH ROUTE"
               end
            else
                return "NO SUCH ROUTE"
            end
        end
        return dist
    end

    # Input: 
    #   -Start and Finish: used to access respective node.
    #   -Steps: indicates how much valid traversal is left
    #   -Use_weight: used to identify whether we are treating
    #       each edge as a single unit or if we're using it's weight
    #       in our travel calculation
    #   -First_call: Avoids counting a single node as a path to itself
    #                   (of distance 0) on first call. Used for cycles.
    #
    # Summary: Function num_trips uses recursion on the stack to navigate 
    #   every path in a DFS. Each valid path returns 1 and an invalid path 
    #   returns 0. These paths are added together as they are returned
    #   from the stack, resulting in the cumulative number of paths that
    #   is returned.
    #
    # Output:          
    #   The total number of paths that can be taken from start to finish
    #   within the span of the steps required.
    #
    # Notes: This method is used for solving #6,7,10.
    #   The if/else statements used to handle
    #   details unique to each problem, but as the process is
    #   similar, they are used in the same function.
    #
    def num_trips(start,finish,steps,use_weight = false,first_call = false)
        count = 0

        if !use_weight
            if steps == 0
                if start == finish then return 1 else return 0 end
            elsif steps < 0
                return 0
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

    # Summary: Method shortest_path uses weighted values in a specialized
    #            BFS search. It starts by finding the shortest path from 
    #            itself to its adjacent neighbors and repeats on those 
    #            neighbors, basing its updated values on nodes known to be
    #            are optimally closest to our start node.
    #          This results in a table of nodes and their respective predecessor
    #            in the determined shortest path. Should we traverse
    #            this path backwards from 'finish' until 'start' we would obtain
    #            our shortest path between the two points. 
    #
    # Output: Value of the shortest distance from the start to finish node
    #           in our graph. A return value of infinity indicates the
    #           lack of a path from the start node to the finish node. 
    #
    # Note: Regarding cycle paths, this particular implementation will 
    #         not return 0 but the length of the shortest path from the
    #         start node back to itself (returning infinity if there is
    #         no cycle).
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

        while !pq.is_empty
            curr = pq.get_top

            for edge in get_node_edges(get_node(curr))
                next_elt = edge.to_node.get_elt
                
                if node_dist[next_elt] > node_dist[curr] + edge.get_weight
                    pq.update_priority(next_elt,
                                       node_dist[curr] + edge.get_weight)
                    prev[get_node(next_elt)] = get_node(curr)
                end
            end
        end

        #Extra check to find shortest (non-zero) cycle path by using our
        #known shortest distances and finding the shortest one back
        #to our start node. It requires another graph traversal in 
        #the worst case.
        node_dist[start] = 1/0.0
        for node in get_all_nodes
            for edge in get_node_edges(node)
                from = edge.from_node.get_elt
                to = edge.to_node.get_elt
                if to == start and node_dist[from] < 1/0.0
                    if node_dist[start] > node_dist[from] + edge.get_weight
                        node_dist[start] = node_dist[from] + edge.get_weight
                        prev[get_node(start)] = get_node(from)
                        break
                    end
                end
            end
        end

        return node_dist[finish]
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
