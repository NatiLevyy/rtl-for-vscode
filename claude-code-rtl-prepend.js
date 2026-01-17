/** RTL Support for Claude Code - Prepend Version */
;(function(){
    if(window._rtlAgentInjected)return;
    window._rtlAgentInjected=true;

    const RTL_RANGES=[[0x0590,0x05FF],[0x0600,0x06FF],[0x0750,0x077F],[0x08A0,0x08FF]];
    const isRTL=t=>{if(!t)return false;for(let i=0;i<t.length;i++){const c=t.charCodeAt(i);for(const[s,e]of RTL_RANGES)if(c>=s&&c<=e)return true;}return false;};
    const getFirstText=el=>{if(!el||el.tagName==='PRE'||el.tagName==='CODE')return'';for(const n of el.childNodes)if(n.nodeType===3&&n.textContent.trim())return n.textContent.trim();for(const c of el.children){if(c.tagName==='PRE'||c.tagName==='CODE')continue;const t=getFirstText(c);if(t)return t;}return'';};

    const applyRTL=el=>{
        if(!el||el.getAttribute('data-rtl'))return;
        el.style.direction='rtl';
        el.style.textAlign='right';
        el.style.fontFamily='"Segoe UI","Arial Hebrew",sans-serif';
        el.setAttribute('data-rtl','1');
        el.querySelectorAll('p,li,h1,h2,h3,h4,h5,h6,div,span').forEach(x=>{
            if(isRTL(x.textContent)&&!x.closest('pre,code')){
                x.style.direction='rtl';
                x.style.textAlign='right';
            }
        });
        el.querySelectorAll('ul,ol').forEach(x=>{
            if(isRTL(x.textContent)){
                x.style.direction='rtl';
                x.style.paddingRight='20px';
                x.style.paddingLeft='0';
            }
        });
        el.querySelectorAll('pre,code').forEach(x=>{
            x.style.direction='ltr';
            x.style.textAlign='left';
        });
    };

    const process=()=>{
        document.querySelectorAll('div').forEach(el=>{
            if(isRTL(getFirstText(el))&&!el.getAttribute('data-rtl'))applyRTL(el);
        });
        document.querySelectorAll('[contenteditable]').forEach(el=>{
            const t=el.textContent||'';
            if(isRTL(t)){el.style.direction='rtl';el.style.textAlign='right';}
            else{el.style.direction='ltr';el.style.textAlign='left';}
        });
    };

    const init=()=>{
        process();
        new MutationObserver(()=>{clearTimeout(window._rtlT);window._rtlT=setTimeout(process,50);})
            .observe(document.body,{childList:true,subtree:true,characterData:true});
        console.log('✅ RTL Active');
    };

    if(document.body)init();
    else document.addEventListener('DOMContentLoaded',init);
    setTimeout(init,500);
    setTimeout(init,2000);
})();
