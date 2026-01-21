/** RTL Support for GitHub Copilot Chat - Prepend Version */
;(function(){
    if(window._rtlCopilotInjected)return;
    window._rtlCopilotInjected=true;

    // RTL character ranges (Hebrew, Arabic, etc.)
    const RTL_RANGES=[[0x0590,0x05FF],[0x0600,0x06FF],[0x0750,0x077F],[0x08A0,0x08FF]];

    const isRTL=t=>{
        if(!t)return false;
        for(let i=0;i<t.length;i++){
            const c=t.charCodeAt(i);
            for(const[s,e]of RTL_RANGES)if(c>=s&&c<=e)return true;
        }
        return false;
    };

    const getFirstText=el=>{
        if(!el||el.tagName==='PRE'||el.tagName==='CODE')return'';
        for(const n of el.childNodes)if(n.nodeType===3&&n.textContent.trim())return n.textContent.trim();
        for(const c of el.children){
            if(c.tagName==='PRE'||c.tagName==='CODE')continue;
            const t=getFirstText(c);if(t)return t;
        }
        return'';
    };

    // Inject RTL CSS styles
    const injectStyles=()=>{
        if(document.getElementById('rtl-copilot-styles'))return;

        const css = `
            /* RTL Support for GitHub Copilot Chat */
            .rendered-markdown[data-rtl="true"] > *:not(pre):not(code):not(.code-block) {
                direction: rtl !important;
                text-align: right !important;
                font-family: "Segoe UI", "Arial Hebrew", "David", sans-serif !important;
            }
            .rendered-markdown[data-rtl="true"] pre,
            .rendered-markdown[data-rtl="true"] code,
            .rendered-markdown[data-rtl="true"] .code-block {
                direction: ltr !important;
                text-align: left !important;
            }
            .rendered-markdown[data-rtl="true"] ul,
            .rendered-markdown[data-rtl="true"] ol {
                padding-right: 20px !important;
                padding-left: 0 !important;
            }
            /* User input RTL */
            [data-rtl-input="true"] {
                direction: rtl !important;
                text-align: right !important;
            }
        `;

        const style = document.createElement('style');
        style.id = 'rtl-copilot-styles';
        style.textContent = css;
        document.head.appendChild(style);
    };

    const applyRTL=el=>{
        if(!el||el.getAttribute('data-rtl'))return;
        el.setAttribute('data-rtl','true');

        // Apply to child elements
        el.querySelectorAll('p,li,h1,h2,h3,h4,h5,h6,div,span').forEach(x=>{
            if(isRTL(x.textContent)&&!x.closest('pre,code')){
                x.style.direction='rtl';
                x.style.textAlign='right';
            }
        });

        // Keep code blocks LTR
        el.querySelectorAll('pre,code').forEach(x=>{
            x.style.direction='ltr';
            x.style.textAlign='left';
        });
    };

    const process=()=>{
        injectStyles();

        // Process rendered markdown containers (Copilot Chat responses)
        document.querySelectorAll('.rendered-markdown').forEach(el=>{
            if(isRTL(getFirstText(el))&&!el.getAttribute('data-rtl')){
                applyRTL(el);
            }
        });

        // Process generic message containers
        document.querySelectorAll('[class*="message"],[class*="chat"],[class*="response"]').forEach(el=>{
            if(isRTL(getFirstText(el))&&!el.getAttribute('data-rtl')){
                applyRTL(el);
            }
        });

        // Process input fields
        document.querySelectorAll('[contenteditable], textarea, input[type="text"]').forEach(el=>{
            const t=el.textContent||el.value||'';
            if(isRTL(t)){
                el.style.direction='rtl';
                el.style.textAlign='right';
                el.setAttribute('data-rtl-input','true');
            } else if(el.getAttribute('data-rtl-input')){
                el.style.direction='ltr';
                el.style.textAlign='left';
                el.removeAttribute('data-rtl-input');
            }
        });
    };

    const init=()=>{
        process();
        new MutationObserver(()=>{
            clearTimeout(window._rtlCopilotT);
            window._rtlCopilotT=setTimeout(process,50);
        }).observe(document.body,{childList:true,subtree:true,characterData:true});
        console.log('✅ RTL Copilot Active');
    };

    if(document.body)init();
    else document.addEventListener('DOMContentLoaded',init);
    setTimeout(init,500);
    setTimeout(init,2000);
})();
