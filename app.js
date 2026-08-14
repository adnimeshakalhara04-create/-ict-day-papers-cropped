(() => {
  const root = document.getElementById('app');
  const data = window.QUIZ_DATA;
  if (!root) return;

  const KEY='ict-day-papers-cropped-v1';
  const total=Array.isArray(data)?data.reduce((s,p)=>s+p.questions.length,0):0;
  if(!Array.isArray(data)||data.length!==21||total!==126){
    root.innerHTML='<main class="quiz"><section class="stage"><div class="answer-box"><div class="feedback bad"><div class="mark">!</div><div><strong>Quiz data validation failed.</strong><p>Expected 21 day papers and 126 questions. Please refresh after the latest deployment finishes.</p></div></div></div></section></main>';
    return;
  }

  let state={screen:'home',mode:'all',paper:null,index:0,answers:{},saved:[],zoom:''};
  const pad=n=>String(n).padStart(2,'0');
  const esc=s=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#039;'}[c]));
  const key=(pn,qn)=>`p${pn}q${qn}`;
  function store(){localStorage.setItem(KEY,JSON.stringify(state));}
  function load(){try{const s=JSON.parse(localStorage.getItem(KEY)||'null');if(s&&s.answers) state={...state,...s,screen:'home',zoom:''};}catch{}}
  function sessionQuestions(){return state.mode==='all'?data.flatMap(p=>p.questions.map(q=>({...q,paper:p.number,title:p.title}))):state.paper.questions.map(q=>({...q,paper:state.paper.number,title:state.paper.title}));}
  function answeredInPaper(p){return p.questions.filter(q=>state.answers[key(p.number,q.number)]!==undefined).length}
  function startPaper(n){
    state.mode='paper';
    state.paper=data.find(p=>p.number===n);
    const nextUnanswered=state.paper.questions.findIndex(q=>state.answers[key(state.paper.number,q.number)]===undefined);
    state.index=nextUnanswered>=0?nextUnanswered:0;
    state.screen='quiz';store();render();scrollTo(0,0)
  }
  function startAll(){state.mode='all';state.paper=null;const qs=data.flatMap(p=>p.questions.map(q=>({...q,paper:p.number})));const next=qs.findIndex(q=>state.answers[key(q.paper,q.number)]===undefined);state.index=next>=0?next:0;state.screen='quiz';store();render();scrollTo(0,0)}
  function choose(c){const qs=sessionQuestions(),q=qs[state.index],k=key(q.paper,q.number);if(state.answers[k]!==undefined)return;state.answers[k]=c;store();render();}
  function nav(delta){const qs=sessionQuestions();state.index=Math.max(0,Math.min(qs.length-1,state.index+delta));store();render();scrollTo(0,0)}
  function toggleSave(){const qs=sessionQuestions(),q=qs[state.index],k=key(q.paper,q.number);state.saved=state.saved.includes(k)?state.saved.filter(x=>x!==k):[...state.saved,k];store();render()}
  function showResults(){state.screen='results';store();render();scrollTo(0,0)}
  function home(){state.screen='home';store();render();scrollTo(0,0)}
  function zoom(src){state.zoom=src;renderModal()}
  function closeZoom(){state.zoom='';renderModal()}
  function bindAssetErrors(){
    root.querySelectorAll('.crop-card img,.marking img').forEach(img=>{
      img.addEventListener('error',()=>{
        const box=img.parentElement;
        img.remove();
        if(box&&!box.querySelector('.asset-error')) box.insertAdjacentHTML('beforeend','<div class="asset-error"><strong>Image load error</strong><span>Latest crop එක load වුණේ නැහැ. Page එක refresh කරලා නැවත බලන්න.</span></div>');
      },{once:true});
    });
  }

  function renderHome(){
    const last=state.mode==='paper'&&state.paper?data.find(p=>p.number===state.paper.number):null;
    root.innerHTML=`<main class="home"><div class="wrap"><header class="header"><div class="brand"><span class="brand-badge">IT</span><span><strong>ICT Day Papers</strong><small>2028 QUIZ STUDIO</small></span></div><div class="pill">PHY 01–21 · Original Sinhala crops</div></header>
    <section class="hero"><div><p class="eyebrow">Information &amp; Communication Technology</p><h1>Turn every day paper<span>into exam-ready practice.</span></h1><p class="lead">ප්‍රශ්න පත්‍ර 21ක ප්‍රශ්න ${total}ම original paper crop ලෙස. පිළිතුරක් තෝරලා ඉවර වුණාම එම ප්‍රශ්නයටම අදාළ official marking explanation crop එකම පෙන්වයි.</p><div class="actions"><button class="btn primary" data-all>ප්‍රශ්න ${total}ම පටන් ගන්න →</button>${last?`<button class="btn secondary" data-paper="${last.number}">දිගටම ${esc(last.title)} <span>${answeredInPaper(last)}/${last.questions.length}</span></button>`:''}</div><div class="stats"><div><strong>${total}</strong><span>QUESTIONS</span></div><div><strong>21</strong><span>DAY PAPERS</span></div><div><strong>5</strong><span>CHOICES EACH</span></div></div></div>
    <div class="demo-wrap"><div class="orbit"></div><div class="orbit b"></div><div class="demo"><div class="demo-top"><span>LIVE PRACTICE</span><span>PHY 01</span></div><div class="track"><i></i></div><div class="mini">QUESTION 5 OF 7</div><h2>Choose your answer</h2><div class="answers-preview">${[1,2,3,4,5].map(n=>`<span class="${n===2?'on':''}">${n}</span>`).join('')}</div><div class="demo-ok"><b>✓</b><div><strong>Official marking crop</strong><small>Sinhala explanation from source</small></div></div></div></div></section>
    <section class="papers"><div class="section-head"><div><p class="eyebrow">PAPER MODE</p><h2>PHY 01 සිට PHY 21 දක්වා</h2></div><p>Paper එකක් තෝරලා එකින් එක practice කරන්න. Progress, score සහ Save කළ ප්‍රශ්න ඔබේ device එකේම තබා ගනී.</p></div><div class="paper-grid">${data.map(p=>{const a=answeredInPaper(p),pc=Math.round(a/p.questions.length*100);return `<button class="paper-card" data-paper="${p.number}"><div class="paper-top"><span class="paper-number">${pad(p.number)}</span><span class="paper-count">${p.questions.length} questions</span></div><h3>${esc(p.title)}</h3><div class="paper-progress"><i style="width:${pc}%"></i></div><div class="paper-foot"><span>${a?`${a}/${p.questions.length} completed`:'Not started'}</span><span>↗</span></div></button>`}).join('')}</div></section><footer class="footer"><span>Source papers & markings: Ravindu Bandaranayake · #ictfromabc.</span><span>Progress is stored only on your device.</span></footer></div></main><div id="modal"></div>`;
    root.querySelector('[data-all]').onclick=startAll;
    root.querySelectorAll('[data-paper]').forEach(b=>b.onclick=()=>startPaper(Number(b.dataset.paper)));
  }

  function renderQuiz(){
    const qs=sessionQuestions(),q=qs[state.index],k=key(q.paper,q.number),picked=state.answers[k],correct=q.answer,done=picked!==undefined,isCorrect=picked===correct,saved=state.saved.includes(k),pct=((state.index+1)/qs.length*100);
    root.innerHTML=`<main class="quiz"><header class="quiz-header"><button class="icon" data-home>←</button><div class="qtitle"><small>${state.mode==='all'?'ALL PAPERS':'PAPER MODE'}</small><strong>${esc(q.title)}</strong></div><div class="counter">${state.index+1}/${qs.length}</div></header><div class="top-progress"><i style="width:${pct}%"></i></div><section class="stage"><div class="qmeta"><div><span class="qkicker">${esc(q.title)} · QUESTION ${q.number}</span><h1>නිවැරදි පිළිතුර තෝරන්න</h1></div><button class="save ${saved?'on':''}" data-save>${saved?'★ Saved':'☆ Save'}</button></div>
    <div class="crop-card"><img src="${q.question}" alt="${esc(q.title)} Question ${q.number}" loading="eager" decoding="async" data-zoom="${q.question}"></div>
    <div class="answer-box"><div class="answer-head"><strong>ඔබේ පිළිතුර</strong><span>Select 1–5</span></div><div class="choices">${[1,2,3,4,5].map(c=>{let cls='';if(done)cls=c===correct?'correct':c===picked?'wrong':'dim';return `<button class="choice ${cls}" data-choice="${c}" ${done?'disabled':''}>${c}${cls==='correct'?'<i>✓</i>':cls==='wrong'?'<i>×</i>':''}</button>`}).join('')}</div>${done?`<div class="feedback ${isCorrect?'good':'bad'}"><div class="mark">${isCorrect?'✓':'!'}</div><div><strong>${isCorrect?'නිවැරදියි!':'වැරදියි — marking එක බලන්න.'}</strong><p>Official marking පිළිතුර ${correct}.</p></div></div><section class="marking"><small>OFFICIAL MARKING REVIEW</small><h2>මේ ප්‍රශ්නයට අදාළ විවරණය</h2><img src="${q.marking}" alt="${esc(q.title)} Question ${q.number} marking" loading="eager" decoding="async" data-zoom="${q.marking}"></section>`:''}</div>
    <div class="nav"><button data-prev ${state.index===0?'disabled':''}>← Previous</button><span>${state.index+1} / ${qs.length}</span><button class="next" data-next>${state.index===qs.length-1?'View results':done?'Next':'Skip'} →</button></div></section></main><div id="modal"></div>`;
    root.querySelector('[data-home]').onclick=home;root.querySelector('[data-save]').onclick=toggleSave;
    root.querySelectorAll('[data-choice]').forEach(b=>b.onclick=()=>choose(Number(b.dataset.choice)));
    root.querySelector('[data-prev]').onclick=()=>nav(-1);
    root.querySelector('[data-next]').onclick=()=>state.index===qs.length-1?showResults():nav(1);
    root.querySelectorAll('[data-zoom]').forEach(img=>img.onclick=()=>zoom(img.dataset.zoom));
    bindAssetErrors();
  }

  function renderResults(){
    const qs=sessionQuestions();let answered=0,correct=0;qs.forEach(q=>{const v=state.answers[key(q.paper,q.number)];if(v!==undefined)answered++;if(v===q.answer)correct++});const wrong=answered-correct,unanswered=qs.length-answered,pct=Math.round(correct/qs.length*100);
    root.innerHTML=`<main class="results"><section class="result-card"><p class="eyebrow">SESSION COMPLETE</p><div class="score" style="--score:${pct*3.6}deg"><div><strong>${pct}%</strong><span>නිවැරදි ප්‍රතිශතය</span></div></div><h1>${pct>=80?'ඉතා හොඳයි!':pct>=60?'හොඳ ප්‍රගතියක්.':'තව practice කරමු.'}</h1><p>${state.mode==='all'?'PHY 01–21 සියල්ල':esc(state.paper.title)} · ${correct}/${qs.length} නිවැරදි</p><div class="result-stats"><div><span>නිවැරදි</span><strong>${correct}</strong></div><div><span>වැරදි</span><strong>${wrong}</strong></div><div><span>නොකළ</span><strong>${unanswered}</strong></div></div><div class="actions" style="justify-content:center"><button class="btn primary" data-review>ප්‍රශ්න නැවත බලන්න →</button><button class="btn secondary" style="color:#263956;border-color:#dce5f1;background:#f6f8fc" data-home>පේපර් ලැයිස්තුව</button></div></section></main><div id="modal"></div>`;
    root.querySelector('[data-review]').onclick=()=>{state.screen='quiz';state.index=0;store();render();};root.querySelector('[data-home]').onclick=home;
  }
  function renderModal(){const m=document.getElementById('modal');if(!m)return;if(!state.zoom){m.innerHTML='';return;}m.innerHTML=`<div class="modal open"><button data-close>×</button><img src="${state.zoom}" alt="Expanded crop"></div>`;m.querySelector('[data-close]').onclick=closeZoom;m.querySelector('.modal').onclick=e=>{if(e.target.classList.contains('modal'))closeZoom()}}
  function render(){if(state.screen==='home')renderHome();else if(state.screen==='quiz')renderQuiz();else renderResults();renderModal();}
  load();render();
})();
