const ASSET_VERSION = '20260819-r7';

window.QUIZ_DATA = [
  {n:1,a:[2,3,2,4,2,2,5]},
  {n:2,a:[2,2,2,3,3,2]},
  {n:3,a:[4,3,3,4,2,3,3]},
  {n:4,a:[4,3,3,3,3,5,1]},
  {n:5,a:[4,2,3,2,4,3]},
  {n:6,a:[3,3,2,2,2]},
  {n:7,a:[2,2,3,1,1]},
  {n:8,a:[3,1,2,3,1]},
  {n:9,a:[3,1,2,2,2,3]},
  {n:10,a:[1,3,2,2,2,2]},
  {n:11,a:[3,3,3,4]},
  {n:12,a:[5,2,3,4,1,2]},
  {n:13,a:[3,1,4,2,3,1]},
  {n:14,a:[2,1,2,2,5,3]},
  {n:15,a:[3,2,4,3,2,5,3]},
  {n:16,a:[4,2,3,3,2,2,3]},
  {n:17,a:[3,3,3,2,5,5,3,3]},
  {n:18,a:[4,3,4,3,3,2,3,3]},
  {n:19,a:[1,2,3,1]},
  {n:20,a:[3,1,2,3,2,3]},
  {n:21,a:[4,1,2,2]},
  {n:22,a:[3,3,5,3,3,2]}
].map(p => ({
  number:p.n,
  title:`PHY ${String(p.n).padStart(2,'0')}`,
  answers:p.a,
  questions:p.a.map((answer,i)=>{
    const folder=`phy-${String(p.n).padStart(2,'0')}`;
    const file=`q-${String(i+1).padStart(2,'0')}`;
    const ext=p.n===22?'png':'webp';
    return {
      number:i+1,
      answer,
      question:`assets/questions/${folder}/${file}.${ext}?v=${ASSET_VERSION}`,
      marking:`assets/markings/${folder}/${file}.${ext}?v=${ASSET_VERSION}`
    };
  })
}));
