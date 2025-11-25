arr = {2:1,3:1,4:1}
arr[1] = 1
print(arr[2])
print(arr.get(1))

# --- Function in a function----
def funcfunc(func, value):
    return value + func(value)

print(funcfunc(lambda x: x*x, 5))


# --- MAP
def square(val):
    return val * val

lst = [1,2,3,4,5]
print(list(map(square, lst)))
print(list(map(lambda x: x*x, lst)))


# --- FILTER
def filtr(val):
    return val*val>val
print(list(filter(filtr, lst)))
print(list(filter(lambda x: x*x>x, lst)))


# --- REDUCE
from functools import reduce
print((reduce(lambda x,y: x+y, lst))) 

a = [1,2,34]
b = [1,2,34]

print(a is b)

a = 34
b = 34
print(a is b)