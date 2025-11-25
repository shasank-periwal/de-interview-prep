tup = (1,2,3)

print(dir(tup))

class Me:
    classVar = "sdcsd"
    def __init__(self) -> None:
        self.name = "Shasank"
        self.age = 23
m = Me()
print(m.__dict__)

# print(help(tup)) 