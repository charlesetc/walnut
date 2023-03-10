# walnut

Walnut is a new interface for persistent state.

Want to save something to disk? Create a 'Walnut Object' like so:

```ruby
haru = :dog.(name: "Haru")  
```

...and it's been saved!

Want to get all the `:dog`'s?

```ruby
irb> :dog.all
=> [:dog.(name: "Haru")]
```

We can get a single dog by name:

```ruby
irb> haru = :dog.find_one(name: "Haru")
=> :dog.(name: "Haru")
```

This data is persisted in the `./store` directory. Any time you mutate a field of a Walnut Object, the change gets persisted immediately to disk:

```ruby
irb> haru.name = 'Haru the Dog'
irb> `cat store/dog-*`
=> "{\"name\":\"Haru the Dog\"}
```

Lastly, we can use `find_many` to filter by a particular attribute:

```ruby
irb> :dog.(name: "Momo")
irb> :dog.all
=> [:dog.(name: "Haru the Dog"), :dog.(name: "Momo")]
irb> :dog.find_many(name: "Momo")
=> [:dog.(name: "Momo")]
```

## installation

```bash
git clone https://github.com/charlesetc/walnut
make
```

And now `irb -r walnut` should work.

## future work

- Support for atomic transactions.
- It would be nice to have a better story/pattern for changing the data layout, i.e. some standardization of migrations.
- When an object is removed, its references should be too. How would this play with non-null type guarantees? Maybe you can only remove if there are no references?

## todos

- [ ] describe sub-references in the readme
- [ ] recursive references aren't supported well at the moment
- [ ] add homogeneous data constraint
