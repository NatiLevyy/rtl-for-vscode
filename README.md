# תמיכת RTL ל-Claude Code ו-Google Antigravity

תוסף שמאפשר כתיבה בעברית (וערבית) ב-Claude Code וב-Google Antigravity עם יישור נכון מימין לשמאל.

## התקנה מהירה (Windows)

### שלב 1: הורד את הקבצים
הורד את כל התיקייה הזו למחשב שלך.

### שלב 2: הרץ את סקריפט ההתקנה
1. לחץ קליק ימני על `install.ps1`
2. בחר **"Run with PowerShell"**
3. אם מופיעה שאלה על הרשאות - אשר

**או** פתח PowerShell והרץ:
```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

### שלב 3: אתחל את VS Code
1. סגור את VS Code לחלוטין
2. פתח מחדש
3. פתח את Claude Code
4. כתוב בעברית - זה עובד! 🎉

## מה הסקריפט עושה?

1. **מעתיק קבצי RTL** לתיקייה `C:\Users\שם_משתמש\vscode-custom\`
2. **מגדיר הפעלה אוטומטית** - הסקריפט ירוץ בכל הפעלת Windows
3. **מכבה עדכונים אוטומטיים** של תוספים (כדי שה-RTL לא יימחק)
4. **מזריק RTL** לכל גרסאות Claude Code ו-Antigravity

## אם RTL מפסיק לעבוד

אם עדכנת את Claude Code ו-RTL הפסיק לעבוד, פשוט הרץ:
```powershell
C:\Users\שם_משתמש\vscode-custom\rtl-auto-inject.ps1
```

## קבצים בחבילה

| קובץ | תיאור |
|------|-------|
| `install.ps1` | סקריפט התקנה ראשי |
| `claude-code-rtl-prepend.js` | קוד RTL ל-Claude Code |
| `antigravity-rtl-prepend.js` | קוד RTL ל-Google Antigravity |
| `rtl-auto-inject.ps1` | סקריפט שמזריק RTL אוטומטית |
| `rtl-auto-inject.vbs` | עוטף להפעלה שקטה |

## פתרון בעיות

### RTL לא עובד בחלון חדש
הרץ את `rtl-auto-inject.ps1` ואתחל את VS Code.

### RTL לא עובד אחרי עדכון
1. הרץ את `rtl-auto-inject.ps1`
2. אתחל את VS Code

### לבדוק אם הסקריפט רץ
בדוק את קובץ הלוג:
```
C:\Users\שם_משתמש\vscode-custom\rtl-inject.log
```

## הסרה

אם תרצה להסיר את RTL:
1. מחק את התיקייה `C:\Users\שם_משתמש\vscode-custom\`
2. מחק את `rtl-injector.vbs` מתיקיית Startup
3. הרץ `regedit` ומחק את `RTLInjector` מתחת ל:
   `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run`

---

נוצר עם ❤️ לדוברי עברית וערבית
