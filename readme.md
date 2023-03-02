# walnut

Walnut is a new interface for persistent state.

Want to save something to disk? Create a 'Walnut Object' like so:

```ruby
:dog.({name: "Haru"})  
```

...and it's been saved.

Want to get all the `:dog`'s?

```ruby
irb> Walnut.find :dog
=> [:dog.({name: "Haru"})]
```

This is a ruby array:

```ruby
irb> haru = (Walnut.find :dog)[0]
=> :dog.({name: "Haru"})
```

This data is persisted in the `./store` directory. Any time you mutate a field of a Walnut Object, the change gets persisted immediately to disk:

```ruby
irb> dog.name = 'Haru the Dog'
irb> `cat store/dog-*`
=> "{\"name\":\"Haru the Dog\"}
```

## future work

- Support for atomic transactions.
- It would be nice to have a better story/pattern for changing the data layout, i.e. some standardization of migrations.


## todos

- [ ] describe sub-references in the readme
- [ ] recursive references aren't supported well at the moment
- [ ] add homogeneous data constraint
