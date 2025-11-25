# class Node:
#     def __init__(self, value):
#         self.data = value 
#         self.next = None 

# class LinkedList:
#     def __init__(self):
#         self.head = None 

#     def insert_at_beginning(self, value):
#         node = Node(value)
#         if self.head == None:
#             self.head = node
#         else:
#             node.next = self.head
#             self.head = node 
    
#     def insert_at_end(self, value):
#         node = Node(value)
#         if self.head == None:
#             self.head = node
#         else:
#             temp = self.head
#             while temp.next:
#                 temp = temp.next
#             temp.next = node 
    
#     # decorator
#     def decorate(func):
#         def mfunc(*args, **kwargs):
#             print("This is how decorators work")
#             func(*args, **kwargs)
#         return mfunc

#     @decorate
#     def print_all(self, val):
#         temp = self.head 
#         while temp.next:
#             print(temp.data, end="->")
#             temp = temp.next
#         print(temp.data)
#         print(val)

# llist = LinkedList()
# llist.insert_at_beginning(3)
# llist.insert_at_beginning(1)
# llist.insert_at_beginning(2)
# llist.insert_at_end(4)
# llist.insert_at_end(5)

# llist.print_all(5)
    
# class MyClass:
#     no_of_employees = 0
#     def __init__(self):
#         self._nonmangled_attribute = "I am a nonmangled attribute"
#         self.__mangled_attribute = "I am a mangled attribute"

# my_object = MyClass()

# print(my_object._nonmangled_attribute) # Output: I am a nonmangled attribute
# try:
#     print(my_object.__mangled_attribute) # Throws an AttributeError
# except Exception as e:
#     print(e)
# print(my_object._MyClass__mangled_attribute) # Output: I am a mangled attribute
# print(my_object.__dir__())


# # Any object first searches for instance variable and then class variable
# #     no_of_employees in MyClass is an example of Class variable
# # Can also me accessed by 
# print(MyClass.no_of_employees)

# # Class method makes changes to the class variables, can be used as constructot
# class ExampleClass:
#     noOfChanges = 0
#     @classmethod
#     def factory_method(cls,  argument2):
#         cls.noOfChanges = argument2

# exClss = ExampleClass()
# print(exClss.noOfChanges)
# exClss.factory_method(4)
# print(exClss.noOfChanges)


name: str = 'Shasank'
age: int = 'Eleven'

print(age)