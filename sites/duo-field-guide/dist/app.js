'use strict';
const poses = {
  outer: {
    label:'OUTER DISPLAY', title:'A smaller space.\nThe same app.', description:'Keep the current task and selection. Let system containers place the controls along the camera edge, and use the remaining safe area for content.', width:'Compact',bars:'On the side',watch:'The outer camera',caption:'The outer camera is always a reserved region.',alt:'Closed outer display: one note, vertical controls on the camera edge, and the outer camera reserved region.',filename:'SystemNavigation.swift',code:'TabView {\n    Tab("Notes", systemImage: "note.text") {\n        NavigationStack {\n            NotesView()\n        }\n    }\n}',note:'Tab: iOS 18+ · Build with the 27.1+ SDK for Duo side bars.',source:'https://developer.apple.com/iphone-duo/prepare/'
  },
  open: {
    label:'INNER · LANDSCAPE',title:'More space.\nMore context.',description:'A list and its detail can sit together when space allows. Keep side controls consistent with the outer display; preserve the same navigation state.',width:'Regular',bars:'On the side',watch:'State continuity',caption:'A fully open fold does not need an active division gutter.',alt:'Fully open inner landscape display: list and detail share the space, with vertical controls and no active fold gutter.',filename:'AdaptiveNavigation.swift',code:'NavigationSplitView {\n    NoteList()\n} detail: {\n    NoteDetail()\n}\n// Let the container adapt to available space.',note:'NavigationSplitView: iOS 16+ · Your views supply the content.',source:'https://developer.apple.com/documentation/swiftui/navigationsplitview'
  },
  portrait: {
    label:'INNER · PORTRAIT',title:'The horizontal\nexception.',description:'The inner display in portrait has room for standard horizontal bars. Keep the same actions in their containers; the system handles placement.',width:'Regular',bars:'Horizontal',watch:'Available height',caption:'Inner portrait keeps standard horizontal controls.',alt:'Inner display in portrait: the same note interface with horizontal controls at the top and no active fold.',filename:'ContainerOwnedBars.swift',code:'NavigationStack {\n    NotesView()\n        .toolbar {\n            Button("Compose",\n                   systemImage: "square.and.pencil",\n                   action: compose)\n        }\n}',note:'Pattern · NotesView and compose are your app’s content and action.',source:'https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo#Vertical-controls'
  },
  book: {
    label:'BOOK POSE',title:'The fold is a region.\nNot a layout trigger.',description:'Let a split view rebalance its panes. For custom controls, query the division region and move only what needs to stay visible.',width:'Regular',bars:'On the side',watch:'The center fold',caption:'A reserved region keeps important content clear of the fold.',alt:'Book pose: a list and detail on either side of the fold, with controls on the physical outer edge.',filename:'ReservedRegions.swift',code:'// Inside a GeometryReader:\nlet fold = geometry.reservedRegions(\n    kind: .division\n)\n\n// Lay out custom controls around region.frame.\n// Use .occlusion for camera regions.',note:'iOS 27.1+ · geometry is the GeometryReader’s proxy.',source:'https://developer.apple.com/documentation/swiftui/reservedregion'
  },
  tabletop: {
    label:'TABLETOP POSE',title:'Content above.\nInteraction within reach.',description:'A tabletop layout is optional. An overlay arrangement can separate primary controls and secondary content around the horizontal fold while keeping navigation outside.',width:'Regular',bars:'Horizontal',watch:'The horizontal fold',caption:'An optional arrangement keeps related content and controls together.',alt:'Tabletop diagram: reading content above a horizontal fold and supporting content below, with horizontal system controls.',filename:'ContentArrangement.swift',code:'NavigationStack {\n    ArrangementView {\n        ControlsView()\n    } secondary: {\n        ContentView()\n    }\n    .arrangementViewStyle(.overlay)\n}',note:'iOS 27.1+ · Example views are placeholders for your own content.',source:'https://developer.apple.com/documentation/swiftui/arrangementview'
  },
  split: {
    label:'SPLIT VIEW MULTITASKING',title:'Your app is only\npart of the display.',description:'Each app places side controls on its outer edge. Read the actual view’s size and safe areas; do not assume a fixed size class or symmetric insets.',width:'Use actual traits',bars:'Each outer edge',watch:'Asymmetric insets',caption:'A second app changes your available space. Read the view, not the screen.',alt:'Two apps share the inner display. The left app has controls at the left edge and the right app at the right edge.',filename:'AvailableSpace.swift',code:'// UIKit: size from the current view.\nlet contentFrame = view.bounds.inset(\n    by: view.safeAreaInsets\n)\n\n// Re-read when the view’s size changes.\n// Avoid subtracting one inset twice.',note:'Pattern · Split View size classes depend on the space available.',source:'https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo#Vertical-controls'
  }
};
const lessons = {
  audit:{file:'Terminal · from the repository root',code:'S=skills/iphone-duo-design/scripts/audit_duo_readiness.sh\n\nbash "$S" tests/fixtures/NotesApp -s\nbash "$S" tests/fixtures/NotesApp -q\n\n# Summary first. Then inspect the source lines.\n# Exit 1 means candidates to review.',result:'11 lines · 9 categories',detail:'Verified output from the bundled Notes fixture. The scanner is read-only; it does not fix code.'},
  tabs:{file:'NotesRootView.swift · excerpt',code:'TabView(selection: $selectedTab) {\n    Tab("Notes", systemImage: "note.text", value: 0) {\n        NotesListView()\n    }\n    Tab("Search", systemImage: "magnifyingglass", value: 1) {\n        Text("Search View")\n    }\n    // Keep the Settings tab too — see the full tutorial.\n}',result:'5 lines · 5 categories remain',detail:'After the full root-view replacement: fixed screen width, manual insets, and homemade tab controls are gone.'},
  toolbar:{file:'NotesListView.swift · toolbar excerpt',code:'.toolbar {\n    ToolbarItemGroup(placement: .topBarTrailing) {\n        Button("Compose", systemImage: "square.and.pencil",\n               action: compose)\n    }\n    .visibilityPriority(.high)\n    ToolbarOverflowMenu {\n        Button("Sort by Date", action: sort)\n        // Keep Select Notes and Settings here too.\n    }\n}',result:'1 line · the grid still needs review',detail:'After the full toolbar fix: the fixed three-column grid remains. Do not equate a smaller count with a ready app.'}
};
const $ = id => document.getElementById(id);
const escapeHTML = value => value.replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
function highlight(value){
  const tokens=/(\/\/[^\n]*|#[^\n]*|"(?:\\.|[^"\\])*"|\b(?:let|var|by|kind|secondary|action|systemImage|value|selection)\b|\b(?:NavigationStack|NavigationSplitView|TabView|Tab|ToolbarItemGroup|ToolbarOverflowMenu|ArrangementView|Button|Text)\b)/g;
  let last=0,result='';
  for(const match of value.matchAll(tokens)){
    result+=escapeHTML(value.slice(last,match.index));
    const token=match[0];const type=token.startsWith('//')||token.startsWith('#')?'comment':token.startsWith('"')?'string':/^[A-Z]/.test(token)?'type':'keyword';
    result+=`<span class="token-${type}">${escapeHTML(token)}</span>`;last=match.index+token.length;
  }
  return result+escapeHTML(value.slice(last));
}
function setPose(key){
  if(!poses[key]) key='book';
  const p=poses[key]; $('device-stage').dataset.pose=key;
  $('stage-width').textContent=(key==='split'?'AVAILABLE SPACE':p.width.toUpperCase()+' WIDTH')+' ↔';
  $('stage-label').textContent=p.label; $('state-title').replaceChildren(...p.title.split('\n').flatMap((text,i)=>i?[document.createElement('br'),document.createTextNode(text)]:[document.createTextNode(text)]));
  $('state-description').textContent=p.description; $('fact-width').textContent=p.width; $('fact-bars').textContent=p.bars; $('fact-watch').textContent=p.watch;
  $('stage-caption').textContent=p.caption; $('device').setAttribute('aria-label',p.alt);
  $('code-title').textContent=p.filename; $('pose-code').innerHTML=highlight(p.code); $('code-caption').textContent=p.note;
  $('state-source').href=p.source;
  $('camera-toggle').disabled=key==='outer';
  for(const button of document.querySelectorAll('.pose-picker button'))button.setAttribute('aria-pressed',String(button.dataset.pose===key));
  updateRegions();
}
function updateRegions(){
  $('device-stage').dataset.regions=String($('regions-toggle').checked);
  $('device-stage').dataset.camera=String($('camera-toggle').checked&&!$('camera-toggle').disabled);
  const p=poses[$('device-stage').dataset.pose];
  $('device').setAttribute('aria-label',p.alt+($('camera-toggle').checked&&!$('camera-toggle').disabled?' Inner camera is active.':'')+(!$('regions-toggle').checked?' Region guides are hidden.':''));
}
function setLesson(key){
  const lesson=lessons[key]; $('lesson-code').innerHTML=highlight(lesson.code);$('lesson-filename').textContent=lesson.file;$('lesson-result').textContent=lesson.result;$('lesson-detail').textContent=lesson.detail;
  for(const button of document.querySelectorAll('.lesson-button'))button.setAttribute('aria-pressed',String(button.dataset.lesson===key));
}
for(const button of document.querySelectorAll('.pose-picker button'))button.addEventListener('click',()=>setPose(button.dataset.pose));
for(const button of document.querySelectorAll('.lesson-button'))button.addEventListener('click',()=>setLesson(button.dataset.lesson));
$('regions-toggle').addEventListener('change',updateRegions);$('camera-toggle').addEventListener('change',updateRegions);
let toastTimer;
for(const button of document.querySelectorAll('[data-copy]'))button.addEventListener('click',async()=>{
  const text=$(button.dataset.copy).textContent;
  try{
    if(!navigator.clipboard)throw new Error('Clipboard unavailable');
    await navigator.clipboard.writeText(text);$('toast').textContent='Copied to clipboard';
  }catch{
    const range=document.createRange();range.selectNodeContents($(button.dataset.copy));const selection=window.getSelection();selection.removeAllRanges();selection.addRange(range);$('toast').textContent='Code selected. Press ⌘C or Ctrl+C to copy.';
  }
  $('toast').classList.add('visible');clearTimeout(toastTimer);toastTimer=setTimeout(()=>$('toast').classList.remove('visible'),3000);
});
setPose('book');setLesson('audit');
