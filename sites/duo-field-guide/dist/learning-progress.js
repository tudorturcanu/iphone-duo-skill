/* Exercise progress stores milestones only. Draft text never enters storage. */
(function (root) {
  'use strict';
  const exercises = {
    meet: [['open', 'Open the inner display'], ['book', 'Find the fold in Book pose'], ['portrait', 'Compare the bars in Portrait']],
    resize: [['narrow-fixed', 'Narrow the fixed-width implementation'], ['narrow-adaptive', 'Try Adaptive at the same narrow width'], ['wide-adaptive', 'Expand Adaptive to show both panes']],
    regions: [['tabletop', 'Turn the fold into a horizontal division'], ['camera', 'Activate the inner camera'], ['guides-hidden', 'Hide the guides; keep the layout safe']],
    bars: [['portrait', 'See horizontal bars in Portrait'], ['side', 'Return the controls to the side'], ['overflow', 'Open the system overflow example']],
    state: [['edited', 'Write your own draft'], ['closed', 'Close the device with that draft selected'], ['reopened', 'Reopen it and keep the same words']],
    build: [['legacy', 'See the iOS 26 compatibility layout'], ['current', 'Compare the iOS 27.1 layout'], ['quiz', 'Answer all three knowledge checks']]
  };
  class Progress {
    constructor(saved) {
      this.steps = Object.fromEntries(Object.keys(exercises).map(id => [id, new Set()]));
      this.lastChapter = 'meet';
      this.continuity = null;
      if (!saved || typeof saved !== 'object' || saved.version !== 2) return;
      for (const [id, definitions] of Object.entries(exercises)) {
        const values = saved.steps?.[id];
        if (!Array.isArray(values)) continue;
        const allowed = new Set(definitions.map(([key]) => key));
        values.filter(key => allowed.has(key)).forEach(key => this.steps[id].add(key));
      }
      // An incomplete continuity exercise needs a fresh draft after a reload.
      if (!this.isComplete('state')) this.steps.state.clear();
      if (Object.hasOwn(exercises, saved.lastChapter)) this.lastChapter = saved.lastChapter;
    }
    isComplete(id) { return exercises[id].every(([key]) => this.steps[id].has(key)); }
    completed() { return Object.keys(exercises).filter(id => this.isComplete(id)); }
    visit(id) { if (Object.hasOwn(exercises, id)) this.lastChapter = id; }
    record(id, event) {
      if (!Object.hasOwn(exercises, id)) return;
      const done = this.steps[id];
      if (id === 'meet' && event.type === 'pose' && ['open', 'book', 'portrait'].includes(event.pose)) done.add(event.pose);
      if (id === 'resize' && event.type === 'layout') {
        if (event.width < 560) done.add(event.fragile ? 'narrow-fixed' : 'narrow-adaptive');
        else if (!event.fragile && done.has('narrow-adaptive')) done.add('wide-adaptive');
      }
      if (id === 'regions') {
        if (event.type === 'pose' && event.pose === 'tabletop') done.add('tabletop');
        if (event.type === 'camera' && event.active) done.add('camera');
        if (event.type === 'guides' && !event.visible) done.add('guides-hidden');
      }
      if (id === 'bars') {
        if (event.type === 'pose' && event.pose === 'portrait') done.add('portrait');
        if (event.type === 'pose' && ['open', 'outer'].includes(event.pose) && done.has('portrait')) done.add('side');
        if (event.type === 'overflow' && event.open) done.add('overflow');
      }
      if (id === 'state') {
        if (event.type === 'draft') {
          this.continuity = { note: event.note, text: event.text, closed: false };
          if (!this.isComplete('state')) { done.clear(); done.add('edited'); }
        }
        if (event.type === 'pose' && this.continuity && event.note === this.continuity.note && event.text === this.continuity.text) {
          if (event.pose === 'outer') { this.continuity.closed = true; done.add('closed'); }
          if (event.pose === 'open' && this.continuity.closed) done.add('reopened');
        }
      }
      if (id === 'build') {
        if (event.type === 'sdk' && event.sdk === '26') done.add('legacy');
        if (event.type === 'sdk' && event.sdk === '27.1' && done.has('legacy')) done.add('current');
        if (event.type === 'quiz' && event.correctCount === 3) done.add('quiz');
      }
    }
    snapshot() {
      return { version: 2, lastChapter: this.lastChapter, steps: Object.fromEntries(Object.entries(this.steps).map(([id, done]) => [id, id === 'state' && !this.isComplete(id) ? [] : [...done]])) };
    }
  }
  const api = { Progress, exercises };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.DuoLearning = api;
})(typeof window === 'undefined' ? {} : window);
