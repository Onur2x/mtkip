self.addEventListener('install',e=>{self.skipWaiting()});
self.addEventListener('activate',e=>{clients.claim()});
self.addEventListener('fetch',e=>{});
self.addEventListener('message',e=>{
  const d=e.data||{};
  if(d.title && self.registration && self.registration.showNotification){
    self.registration.showNotification(d.title,{body:d.body||''});
  }
});
