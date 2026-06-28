// Selkies 客户端的核心 JS 逻辑伪代码
const peerConnection = new RTCPeerConnection(config);

peerConnection.oniceconnectionstatechange = function(event) {
    console.log("WebRTC 物理状态变更为: ", peerConnection.iceConnectionState);
    if (peerConnection.iceConnectionState === "failed" || 
        peerConnection.iceConnectionState === "disconnected") {
        
        // 🚨 触发物理容错：不要等待浏览器自己恢复
        console.warn("检测到服务器底层信道突发断裂，正在强权清除浏览器本地 Session...");
        
        // 物理销毁当前实例
        peerConnection.close();
        
        // 清除当前域名的 SessionStorage 缓存，防止 HTTP/2 帧 ID 套娃
        window.sessionStorage.clear();
        
        // 延迟 1 秒后自动发起洁净重连
        setTimeout(() => {
            window.location.reload(true); // true 代表强制绕过缓存（Force Reload）
        }, 1000);
    }
};
