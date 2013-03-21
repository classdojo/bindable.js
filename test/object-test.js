var BindableObject = require("../").Object,
expect = require("expect.js");

describe("bindable object", function() {

  var bindable;

  it("can be created", function() {
    bindable = new BindableObject({
      name: {
        first: "craig",
        last: "craig"
      },
      location: {
        city: "San Francisco"
      }
    });
  });

  it("can bind to location.zip", function(next) {

    bindable.bind("location.zip", function(value) {
      expect(value).not.to.be(undefined);
      next();
    }).once();

    bindable.set("location.zip", "94102");
  });

  it("can do perform a deep bind", function(next) {
    bindable.bind("a.b.c.d.e", function(value) {
      expect(value).to.be(1);
      next();
    }).once();

    bindable.set("a", { a: { b: {c: { d: { e: 1 }}}}})
  });


  it("can bind to a property", function() {

    bindable.bind("name", "name2").once();
    expect(bindable.get("name2.first")).to.be("craig");

    bindable.bind("doesntexist", "doesntexist2").once();
    expect(bindable.get("doesntexist2")).to.be(undefined);

    bindable.set("doesntexist", 5)
    expect(bindable.get("doesntexist2")).to.be(5);
  });


  it("previous name binding is not bound anymore", function() {
    bindable.set("doesntexist", 6);
    expect(bindable.get("doesntexist2")).to.be(5);
  })

  it("can be bound both ways", function() {
    bindable.bind("age", "age2").botWays().limit(2);

    bindable.set("age", 5);
    expect(bindable.get("age")).to.be(5);
    expect(bindable.get("age2")).to.be(5);


    bindable.set("age2", 6);
    expect(bindable.get("age")).to.be(6);
    expect(bindable.get("age2")).to.be(6);
  });

  it("previous age binding is not bound anymore", function() {
    bindable.set("age", 7);
    bindable.set("age2", 8);
    expect(bindable.get("age")).to.be(6);
    expect(bindable.get("age2")).to.be(6);
  });


  it("can be bound multiple times", function() {
    bindable.bind("count").to("count2").to("count3").once();
    bindable.set("count", 99);
    expect(bindable.get("count")).to.be(99);
    expect(bindable.get("count2")).to.be(99);
    expect(bindable.get("count3")).to.be(99);
  });
});