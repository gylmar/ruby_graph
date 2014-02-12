# Priority Queue implemented using a min-heap structure. 
# Attributes:
#       @heap -> Complete binary tree stored in an array. The heap must 
#                   always adhere to the following property:
#                   1) Every parent element has an equal or lower
#                       priority (as this is a min-heap) than it's children.
#       @index_of -> Used for instant access of our node positions. 
#                    Note: This assumes the elements are unique.
#       @size -> Heap size separate from the size of the array, due
#                   to the 1 offset.
#       @priority -> Hash with priority values of each respective
#                   element.
# Notes: The heap has it's root at 1 (index 0 holds Null) to ease
#           the indexing of elements.
class PriorityQueue
    # Input: Hash of elements and their priorities
    def initialize(elt_priority)
        @heap = [nil]         
        @index_of = {}        
        @size = 0
        @priority = elt_priority 
        for elt in @priority.keys
            insert(elt)
        end
    end

    def is_empty()
        if @size == 0
            return true
        else
            return false
        end
    end

    # Input: Element to add into the heap.
    # Summary: The element is inserted at the
    #   end of the heap and moved upward as 
    #   needed to restore the heap property if
    #   it is violated.
    def insert(elt)
        @heap.push(elt) 
        @size = @size + 1
        @index_of[elt] = @size
        trickle_up(elt)
    end

    # Summary: Replaces the first element of the heap with
    #   the last element and uses heap functions to 
    #   keep its properties. The original first element
    #   is returned.
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

    # Summary: We update the priority of the input element and
    # maintain the heap property using the functions tailored to do so.
    # The trickle functions will not do anything if the heap property has not
    # been violated.
    def update_priority(elt,new_priority)
        index = @index_of[elt]
        @priority[@heap[index]] = new_priority

        trickle_up(@heap[index])
        trickle_down(@heap[index])
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
