#include <cstdint>
#include <exception>

uint64_t EVENTS = 0;

extern "C" uint64_t getEvents() {
    return EVENTS;
}

enum Event {
    FooCreated = 1,
    FooDeleted = 2,
    //
    All = FooCreated | FooDeleted,
};

extern "C" uint64_t allEvents() { return All; }

struct Foo {
    Foo () { EVENTS |= FooCreated; }
    ~Foo() { EVENTS |= FooDeleted; }
};

extern "C" void deleteFoo(Foo * p) { delete p; }
