# Helper Methods 3

The starting point of this project is a solution to Helper Methods after completing Parts 1 & 2.

## Setup

```
bin/setup
```

## Partial view templates

Partial view templates (or just "partials", for short) are an extremely powerful tool to help us modularize and organize our view templates. Especially once we start adding in styling with Bootstrap, etc, our view files will grow to be hundreds or thousands of lines long, so it becomes increasingly helpful to break them up into partials.

### Official docs

[Here is the official article in the Rails API reference describing all the ways you can use partials.](https://edgeapi.rubyonrails.org/classes/ActionView/PartialRenderer.html) There are lots of powerful options available, but for now we're going to focus on the most frequently used ones.

### Getting started: static HTML partials

Create a partial view template in the same way that you create a regular view template, except that the first letter in the file name _must_ be an underscore. This is how we (and Rails) distinguish partial view templates from full view templates.

For example, create a file called `app/views/zebra/_giraffe.html.erb`. Within it, write the following:

```html
<h1>Hello from the giraffe partial!</h1>
```

Then, in any of your other view templates, add:

```html
<%= render template: "zebra/giraffe" %>
```

Notice that **we don't include the underscore when referencing the partial** in the `render` method, even though the underscore must be present in the actual filename.

You can render the partial as many times as you want:

```html
<%= render template: "zebra/giraffe" %>

<hr>

<%= render template: "zebra/giraffe" %>
```

A more realistic example of putting some static HTML into a partial is extracting a 200 line Bootstrap navbar into `app/views/shared/_navbar.html.erb` and then `render`ing it from within the application layout.

### Partials with inputs

Breaking up large templates by putting bits of static HTML into partials is nice, but even better is the ability to dynamically render partials based on varying inputs.

For example, create a file called `app/views/zebra/_elephant.html.erb`. Within it, write the following:

```erb
<h1>Hello, <%= person %>!</h1>
```

Then, in any of your other view templates, try:

```erb
<%= render template: "zebra/elephant" %>
```

When you test it, it will break and complain about an undefined local variable `person`. To fix it, try:

```erb
<%= render template: "zebra/elephant", locals: { person: "Alice" } %>
```

Now it becomes more clear why it can be useful to render the same partial multiple times:

```erb
<%= render template: "zebra/elephant", locals: { person: "Alice" } %>

<hr>

<%= render template: "zebra/elephant", locals: { person: "Bob" } %>
```

If we think of rendering partials as _calling methods that return HTML_, then the `:locals` option is how we _pass in arguments_ to those methods. This allows us to create powerful, reusable HTML components.

### Practical examples

#### The form

In this application, can you find any ERB that's re-used in multiple templates?

Well, since we evolved to using `form_with model: @movie`, the two forms in `movies/new` and `movies/edit` are exactly the same!

1. Let's extract the common ERB into a template called `app/views/movies/_form.html.erb`.
1. Then render it from both places with:

    ```erb
    render template: "movies/form"
    ```
    
If you test it out, you'll notice that it works. However, we're kinda getting lucky here that we named our instance variable the same thing in both actions —— `@movie`. Try making the following variable name changes in `MoviesController`:

```rb
def new
  @new_movie = Movie.new # instead of @movie
end

def edit
  @the_movie = Movie.find(params.fetch(:id)) # instead of @movie
end
```

Now if you test it out, you'll get errors complaining about undefined methods for `nil`, since the `movies/_form` partial expects an instance variable called `@movie` and we're no longer providing it.

So, should we always just use the same exact variable name everywhere? That's not very flexible, and sometimes it's just not possible. Instead, we should use the `:locals` option:

Update the `form` partial to use an arbitrary local variable name, e.g. `foo`, rather than `@movie`:

```erb
<%= form_with model: foo do |form| %>
```

If you test it out now, you'll get the expected "undefined local variable `foo`" error.

But then, in `new`:

```erb
render template: "movies/form", locals: { foo: @new_movie }
```

And in `edit`:

```erb
render template: "movies/form", locals: { foo: @the_movie }
```

If you test it out, everything should be working again. And, it's much better, because the `movies/_form` partial is flexible enough to be called from any template, or multiple times within the same template (e.g. if we wanted to have multiple edit forms on the index page, which is quite common).

So, a rule of thumb: **don't use instance variables within partials**. Instead, prefer to use the `:locals` option and pass in any data that the partial requires, even though it's more verbose to do it that way.

#### An ActiveRecord object


