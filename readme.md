# walnut

Walnut is a new interface for persistent state.

Want to save something to disk? Create a 'Walnut Object' like so:

```ruby
:dog.({name: "Haru"})  
```

...and it's been saved.

Want to get all the `:dog`'s?

```ruby
irb> :dog.find
=> [:dog.({name: "Haru"})]
```

This is a ruby array:

```ruby
irb> haru = :dog.find[0]
=> :dog.({name: "Haru"})
```

This data is persisted in the `./store` directory. Any time you mutate a field of a Walnut Object, the change gets persisted immediately to disk:

```ruby
irb> haru.name = 'Haru the Dog'
irb> `cat store/dog-*`
=> "{\"name\":\"Haru the Dog\"}
```

We can also use `find` to filter by a particular attribute:

```ruby
irb> :dog.({name: "Momo"})
irb> :dog.find
=> [:dog.({name: "Haru"}), :dog.({name: "Momo"})]
irb> :dog.find({name: "Momo"})
=> [:dog.({name: "Momo"})]
```

## installation

```bash
git clone https://github.com/charlesetc/walnut
make
```

And now `irb -r walnut` will work.

## future work

- Support for atomic transactions.
- It would be nice to have a better story/pattern for changing the data layout, i.e. some standardization of migrations.

## todos

- [ ] describe sub-references in the readme
- [ ] recursive references aren't supported well at the moment
- [ ] add homogeneous data constraint
