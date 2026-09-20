/* M8 service worker — kabuk önbelleği (çevrimdışı açılış) + zamanlanmış/yığın bildirimler
   Kabuk değişince VERSIYON'u artır ki telefonlar yeniyi alsın. */
const VERSIYON='m8-v3';
const KABUK=['./','./index.html','./manifest.webmanifest','./supabase-config.js'];
self.addEventListener('install',e=>{
  self.skipWaiting();
  e.waitUntil(caches.open(VERSIYON).then(c=>c.addAll(KABUK).catch(()=>{})).then(()=>{}));
});
self.addEventListener('activate',e=>{
  e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==VERSIYON).map(k=>caches.delete(k)))).then(()=>self.clients.claim()));
});
self.addEventListener('fetch',e=>{
  const u=new URL(e.request.url);
  if(e.request.method!=='GET'||u.origin!==self.location.origin)return; // CDN'ye dokunma
  e.respondWith((async()=>{
    try{
      const r=await fetch(e.request);
      const c=await caches.open(VERSIYON);c.put(e.request,r.clone());
      return r;
    }catch(err){
      const m=await caches.match(e.request);
      if(m)return m;
      if(e.request.mode==='navigate')return caches.match('./index.html');
      throw err;
    }
  })());
});
self.addEventListener('message',e=>{
  const d=e.data||{};
  if(d.title&&self.registration&&self.registration.showNotification){
    self.registration.showNotification(d.title,{body:d.body||''});
  }
});
// Zamanlanmış yerel alarm + ileride sunucu push'u
self.addEventListener('push',e=>{
  const d=e.data?e.data.json():{};
  e.waitUntil(self.registration.showNotification(d.title||'M8', {body:d.body||'',tag:d.tag||'m8'}));
});
self.addEventListener('notificationclick',e=>{
  e.notification.close();
  e.waitUntil(self.clients.matchAll({type:'window'}).then(ws=>{
    if(ws.length)return ws[0].focus();
    return self.clients.openWindow('./index.html');
  }));
});
