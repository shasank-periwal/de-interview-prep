class Generator:
    def gener():
        for i in range(5):
            yield i
    id = gener()

gen = Generator()
print(gen.id)