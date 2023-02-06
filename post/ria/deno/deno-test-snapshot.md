---
title: deno test Snapshot
date: 2023-01-12
private: true
---
# deno test Snapshot
https://deno.land/manual@v1.29.2/basics/testing/snapshot_testing

## Write Test Snapshot

    // example_test.ts
    import { assertSnapshot } from "https://deno.land/std@0.171.0/testing/snapshot.ts";

    Deno.test("isSnapshotMatch", async function (t): Promise<void> {
      const a = {
        hello: "world!",
        example: 123,
      };
      await assertSnapshot(t, a);
    });

    // __snapshots__/example_test.ts.snap
    export const snapshot = {};

    snapshot[`isSnapshotMatch 1`] = `
    {
      example: 123,
      hello: "world!",
    }
    `;

## run test snapshot

    deno test -A 
    # update *.snap data
    deno test -A -- --update

# advanced snapshot
## custom serializer

    /**
     * Serializes `actual` and removes ANSI escape codes.
     */
    function customSerializer(actual: string) {
      return serialize(stripColor(actual));
    }

    Deno.test("Custom Serializer", async function (t): Promise<void> {
      const output = "\x1b[34mHello World!\x1b[39m";
      await assertSnapshot(t, output, {
        serializer: customSerializer,
      });
    });

## name,path

    await assertSnapshot(t, output, {
        serializer: customSerializer,
        // specifies the name of the snapshot: snapshot[`Test Name 1`]
        name: "Test Name",
        // generate snap in `./snaps/*_test.ts.snap`
        dir: "./snaps",
        // generate snap in `./snaps/test.snap`
        path: "./snaps/test.snap"
    });

## default options
    const assertSnapshot = createAssertSnapshot({
        dir: ".snaps",
    });
    const assertMonochromeSnapshot = createAssertSnapshot<string>(
        { serializer: stripColor },
        assertSnapshot,
    );
    ...
      await assertMonochromeSnapshot(t, a);

## serialize for assert and assertSnapshot and ohters
上文中的serializer实际上使用了 `Deno.inspect`.

We can set property `Symbol.for("Deno.customInspect")` to a custom serialization function. 
> it is also used to serialize objects when calling `console.log` and in some other case

    class HTMLTag {
      constructor( public name: string) {}

      public render() {
          return this.name.replaceAll('.','').trim()
      }
      public [Symbol.for("Deno.customInspect")]() {
        return this.render();
      }
    }

    let a=new HTMLTag(". ah .")
    console.log(a) // ah
