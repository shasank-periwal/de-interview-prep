    tuple = ()
    list = []
    set = {a,}

    for index, mark in enumerate(marks, start = 1):
    if name =='__main__', if called by other file,this line returns false

    tuple is faster than list because it is immutable and doesn't have to deal with changes later. So the way values are organized in the memory in case of tuple, it makes it faster.
```python
name: str = 'Shasank'
age: int = 'Eleven'
double = lambda x, y: x*y*2

data.sort(key=lambda x: (x[0], -x[1])) # x[0] ascending; x[1] descending
data.sort(key=lambda x: (x[0], x[1]), reverse=True)
```

Dunder methods, also known as magic methods or special methods, are predefined methods in Python classes that are distinguished by double underscores at both the beginning and end of their names (e.g., `__init__`, `__add__`, `__str__`). The term "dunder" is an abbreviation for "double underscore." 
`__str__`: if we add this dunder method to the class, then when we use print() it'll execute the print function.
`__repr__`: Represent dunder method. Same as str but theoritically should be printing what is useful to the developer. print(repr(classInstance))


Class names follow CamelCase

#### Walrus operator
```python
users = {0: 'Mario', 1: 'Kart'}

# Currently
user: str | None = users.get(3)
if user: 
    print(f'{user.get(0)}')
else:
    print(f'User doesn\'t exist')

# With Walrus Operator
if user := users.get(1)
    print(f'{user.get(0)}')
else:
    print(f"User doesn't exist")
```

```python
class Singleton:
    _instance = None
    _lock = threading.Lock()

    def __new__(cls):
        if cls._instance is None: 
            with cls._lock:
                # Another thread could have created the instance
                # before we acquired the lock. So check that the
                # instance is still nonexistent.
                if not cls._instance:
                    cls._instance = super().__new__(cls)
        return cls._instance
```