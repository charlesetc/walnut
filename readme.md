# walnut

Walnut is a new interface for persistent state.

Want to save something to disk?

```ruby
:dog.({name: "Haru"})  
```

it's been saved. Want to get all the `:dog`'s?

```ruby
irb> Walnut.find :dog
=> [:dog.({name: "Haru"})]
```

This is a normal ruby array:

```ruby
irb> haru = (Walnut.find :dog)[0]
=> :dog.({name: "Haru"})
```

This data is persisted in the `./store` directory. Any mutations get saved to disk immediately:

```ruby
irb> dog.name = 'Haru the Dog'
irb> `cat store/dog-*`
=> "{\"name\":\"Haru\"}
```

## future work

- There is currently no way to do multiple steps atomically. It would be nice to have a lock that allows for atomic transactions.
- It would be nice to have a better story/pattern for changing the data layout, i.e. some standardization of migrations.


## todos

- [ ] describe references in the readme
- [ ] recursive references aren't supported well at the moment
- [ ] add homogeneous data constraint
