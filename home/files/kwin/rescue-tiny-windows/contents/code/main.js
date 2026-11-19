// Rescues windows that are in the task list but cannot be seen:
//  - collapsed to a sliver (seen with Thunderbird's setup windows on Wayland,
//    scaled 1.7x), or
//  - flung outside every screen.
// It runs when a window gets focus (for example from the task list) and when
// you let go of a window you were dragging. A rescued window keeps its size
// (a sliver gets a normal size) and is centered on its screen.
const MIN_SIZE = 40;          // logical px: smaller than this in either direction is a sliver
const VISIBLE_WIDTH = 100;    // a screen must show at least this much of the window
const VISIBLE_HEIGHT = 40;
const RESCUE_WIDTH = 900;     // size given to a sliver
const RESCUE_HEIGHT = 650;

function overlap(a, b) {
    const w = Math.min(a.x + a.width, b.x + b.width) - Math.max(a.x, b.x);
    const h = Math.min(a.y + a.height, b.y + b.height) - Math.max(a.y, b.y);
    return { width: Math.max(0, w), height: Math.max(0, h) };
}

function visibleOnSomeScreen(g) {
    return workspace.screens.some((s) => {
        const o = overlap(g, s.geometry);
        return o.width >= VISIBLE_WIDTH && o.height >= VISIBLE_HEIGHT;
    });
}

function rescue(w) {
    if (!w || !(w.normalWindow || w.dialog) || w.fullScreen || w.minimized || w.tile) {
        return;
    }
    const g = w.frameGeometry;
    const sliver = w.resizeable && (g.width < MIN_SIZE || g.height < MIN_SIZE);
    const stranded = w.moveable && !visibleOnSomeScreen(g);
    if (!sliver && !stranded) {
        return;
    }
    // Center on the window's own screen, or on the active one if it is off all of them
    const output = stranded ? workspace.activeScreen : w.output;
    const area = workspace.clientArea(KWin.PlacementArea, output, workspace.currentDesktop);
    const width = Math.min(sliver ? RESCUE_WIDTH : g.width, area.width);
    const height = Math.min(sliver ? RESCUE_HEIGHT : g.height, area.height);
    print("rescue-tiny-windows: " + w.resourceClass + " \"" + w.caption + "\" "
        + (sliver ? "sliver " : "off-screen ") + Math.round(g.width) + "x" + Math.round(g.height)
        + " at " + Math.round(g.x) + "," + Math.round(g.y));
    w.frameGeometry = {
        x: area.x + (area.width - width) / 2,
        y: area.y + (area.height - height) / 2,
        width: width,
        height: height,
    };
}

function watch(w) {
    if (w.interactiveMoveResizeFinished) {
        w.interactiveMoveResizeFinished.connect(() => rescue(w));
    }
}

workspace.windowActivated.connect(rescue);
workspace.windowAdded.connect(watch);
workspace.windowList().forEach(watch);
