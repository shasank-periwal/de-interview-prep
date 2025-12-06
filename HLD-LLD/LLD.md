## OOPS
Object Oriented Programming - a paradigm that organizes code into objects that represent real-world entities. Foundation being classes and objects - which together enable the creation of structured, reusable and scalable code.

Class is a blueprint for creating objects - defines the `properties`(`attributes`) and `behaviors`(`methods`).
Object is the instance of the class, with it's unique set of data.
Together they enable the creation of modular, reusable and scalable applications.

#### Constructors
Constructors have the same name as the class and do not have a return type, used for `initializing` objects.
Features - `Automatic Invocation`, `No return type`, `Overloading Support `
Constructors - `Default`, `Parameterized`, `Copy`, `Private`
Constructors cannot be inherited, can call the superclass constructor using `super()`

#### Keywords
`final` - Prevents from being overridden in a sub class.
`static` - One instance, can be called by class name directly.
`abstract` - No need of definition, can be given in the future.
`this` - Allows to access the current object's attributes or methods. Cannot be used with `static` methods.

#### Pillars
- Polymorphism 
    - *Static*: Compile Time. Ex: Method Overloading
    - *Dyanmic*: Runtime. Method Overriding --NOTE: Python class a,c,d `extends`/`implements` class b. now b can have list of all instances 52:37
- Inheritance
    - Single, Multilevel, Hierarchical, Multiple `class Employee(Person, Job):`(Diamond Problem)
- Encapsulation
- Abstraction: defining the what of an object (it's behavior) while hiding how of the object(it's implementation).

### DESIGN PRINCIPLES
#### SOLID
>- **S** : Single Responsibility Principle - Class should have a single responsibility or single job or single purpose.
>- **O** : Open/Closed Principle - Open for extension, but Closed for modification.
>- **L** : Liskov's Substitution Principle - Derived or child classes must be substitutable for their base or parent classes.
>- **I** : Interface Segregation Principle - Do not force any client to implement an interface which is irrelevant to them.
>- **D** : Dependency Inversion Principle - High-level modules should not depend on low-level modules. Both should depend on abstractions.

#### DRY - **D**on't **R**epeat **Y**ourself.
>Create reusable components that share common functionality

#### KISS - **K**eep **I**t **S**imple, **S**tupid
>Keep things as simple as possible while still achieving the desired functionality or outcome.

#### YAGNI - **Y**ou **A**ren't **G**onna **N**eed **I**t
>Don't add features or functionality to software that we don't currently need.

### QnA
1. Can a constructor be `final`, `static` or `abstract`?
    
    No, final - Constructor cannot be inherited, so it's irrelevant.
    static - Constructors belong to objects and not the class itself.
    abstract - Constructors must be concrete as it initializes an object.

2. Which constructor is called first when we create and object of a subclass?
    Parent followed by subclass constructor --NOTE: Check