/// Helpers for asynchronously executing code
module mecca.lib.concurrency;

// Licensed under the Boost license. Full copyright information in the AUTHORS file

import core.atomic;

/**
  This struct allows updating complex values (i.e. - values you cannot update atomically) to be read by a signal handler. The
  signal handler has only read-only access, it cannot update the value.
 */
struct SignalHandlerValue(T) {
private:
    T[2] values;
    shared uint index;

public:
    @disable this(this);

    this(T value) nothrow @safe @nogc {
        values[0] = value;
        index = 0;
    }

    void opAssign(T value) nothrow @trusted @nogc {
        // Since we only write from outside the handler, there is no need to do atomic reads of the index, only atomic writes.
        uint nextIndex = (index + 1) % 2;
        values[nextIndex] = value;
        atomicStore(index, nextIndex);
    }

    @property T get() const nothrow @safe @nogc {
        return values[index];
    }

    alias get this;
}

unittest {
    SignalHandlerValue!uint i;

    i = 1;
    assert(i==1);
    i = 2;
    assert(i==2);
}
