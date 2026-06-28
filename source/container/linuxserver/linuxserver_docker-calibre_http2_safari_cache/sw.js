// Service Worker 内部逻辑
const BACKEND_PING_URL = '/kv/ping'; 

// 定期执行边缘探活
setInterval(() => {
    fetch(BACKEND_PING_URL, { cache: 'no-store' })
        .then(response => {
            if (response.status === 502 || response.status === 503) {
                // 🚨 探测到后端已经重置或崩溃！
                triggerSelfDestruct();
            }
        })
        .catch(() => {
            // 网络彻底断开
        });
}, 10000); // 每 10 秒物理心跳一次

function triggerSelfDestruct() {
    // 强权注销当前的 Service Worker，防止其继续拦截请求或锁定 HTTP/2 路由
    self.registration.unregister().then(() => {
        return self.clients.matchAll();
    }).then(clients => {
        clients.forEach(client => {
            // 物理强制前端页面刷向服务器，彻底斩断前世记忆
            client.navigate(client.url);
        });
    });
}
