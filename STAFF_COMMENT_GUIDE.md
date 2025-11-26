# 📱 TaskFlow v2.1 - Staff Comment Features Guide

## 🎯 Quick Start

### How to Add Comments (3 Ways)

TaskFlow now supports **3 types of comments**:

---

## 1️⃣ Text Comments (Default)

**When to use**: Quick updates, status reports, questions

### Steps:
1. Open a task assigned to you
2. Scroll to "Progress Reports" section
3. Type your update in the text box
4. Click the **send icon** (➤)

### Example:
```
"Completed the database migration. 
Moving to frontend integration next."
```

**✅ Best for**: Quick status updates, asking questions, brief reports

---

## 2️⃣ File Attachments

**When to use**: Share documents, images, spreadsheets

### Steps:
1. Open a task assigned to you
2. Tap the **[📎 File]** button at the top
3. Tap **Choose File** button
4. Select file from your device
5. (Optional) Add a description
6. Tap **Submit**

### Supported Files:
- 📄 **Documents**: PDF, DOC, DOCX, TXT
- 🖼️ **Images**: JPG, JPEG, PNG
- 📊 **Spreadsheets**: XLSX, XLS

### Example Use Cases:
- Share completed designs
- Upload specification documents
- Attach screenshots of bugs
- Provide progress reports as PDFs

**✅ Best for**: Documentation, visual proof, formal reports

---

## 3️⃣ Link Sharing

**When to use**: Reference external resources, share URLs

### Steps:
1. Open a task assigned to you
2. Tap the **[🔗 Link]** button at the top
3. Paste or type the URL
4. (Optional) Add a description
5. Click the **send icon** (➤)

### Example:
```
URL: https://figma.com/file/abc123
Description: Updated design mockups for review
```

### Example Use Cases:
- Share design mockups
- Reference documentation
- Link to staging environments
- Share Google Drive folders
- Reference GitHub repos

**✅ Best for**: External resources, design tools, documentation links

---

## 🎨 Comment Type Selector

At the top of the comment box, you'll see:

```
[📝 Text] [🔗 Link] [📎 File]
```

**How to use**:
- Tap any chip to switch modes
- Active mode is highlighted in blue
- Switch anytime before submitting

---

## 📊 Viewing Comments

### All comments show:
- 👤 **User avatar** and name
- 📅 **Date and time** posted
- 💬 **Comment text**
- 📎 **File attachment** (if any)
- 🔗 **Link preview** (if any)

### Visual Indicators:
- **Text comments**: Standard text display
- **File comments**: Shows 📄 with filename
- **Link comments**: Shows 🔗 with clickable link

---

## 💡 Pro Tips

### 1. Combine Text with Attachments
You can add a description when uploading files:
```
File: bug_screenshot.png
Description: "Error appears when clicking Submit button"
```

### 2. Use Links for Collaboration
Share live documents:
```
Link: https://docs.google.com/document/d/...
Description: "Latest project plan - please review"
```

### 3. Quick File Attachments
From text mode, click the 📎 icon next to send button for quick file attachment without switching modes.

### 4. Clear Communication
Always add context:
- ❌ "Here's the file"
- ✅ "Attached the updated requirements document reviewed with client"

---

## 🎯 Best Practices

### For Daily Updates:
- Use **text comments** for quick status updates
- Keep updates concise and clear
- Mention blockers or issues

### For Deliverables:
- Use **file attachments** for completed work
- Add description explaining the deliverable
- Mention what's next

### For Resources:
- Use **link sharing** for external tools
- Always add context about the link
- Update if links change

---

## ❓ Frequently Asked Questions

### Q: Can I attach multiple files?
**A**: Currently one file per comment. Post multiple comments for multiple files.

### Q: What's the file size limit?
**A**: Currently no strict limit. Recommend keeping files under 10MB.

### Q: Can managers add files too?
**A**: Yes! Both staff and managers can use all comment types.

### Q: Can I edit comments?
**A**: Not yet. Double-check before submitting.

### Q: Can I delete comments?
**A**: Not yet. Contact your manager if needed.

### Q: Do links open automatically?
**A**: Link opening will be added soon. Currently shows as preview.

### Q: Where are files stored?
**A**: Files are stored locally on device. Cloud storage coming soon.

### Q: Can I attach images from camera?
**A**: Yes! Use the file picker to choose from camera or gallery.

---

## 🚨 Troubleshooting

### Problem: "File picker not opening"
**Solution**: Check app permissions for storage access

### Problem: "File too large"
**Solution**: Compress file or share via link to cloud storage

### Problem: "Invalid file type"
**Solution**: Only PDF, DOC, DOCX, TXT, JPG, PNG, XLSX, XLS supported

### Problem: "Comment not sending"
**Solution**: 
1. Check internet connection
2. Try again
3. Contact manager if persists

---

## 📱 Interface Guide

### Comment Input Area:

```
┌─────────────────────────────────────────┐
│  Progress Reports                       │
├─────────────────────────────────────────┤
│                                         │
│  [📝 Text] [🔗 Link] [📎 File]         │ ← Select type
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ Add a progress update...        │   │ ← Type here
│  │                                 │   │
│  │                          📎 ➤  │   │ ← Attach or Send
│  └─────────────────────────────────┘   │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Previous comments appear below...      │
└─────────────────────────────────────────┘
```

---

## 🎓 Examples

### Example 1: Daily Status Update
```
Type: Text
Comment: "Completed user authentication module. 
Starting work on dashboard UI next. ETA 2 days."
```

### Example 2: Design Submission
```
Type: File
File: homepage_mockup_v3.pdf
Description: "Updated homepage design based on 
feedback from yesterday's meeting"
```

### Example 3: Reference Sharing
```
Type: Link
URL: https://api-docs.example.com
Description: "API documentation for payment gateway 
integration we discussed"
```

### Example 4: Bug Report
```
Type: File
File: error_screenshot.png
Description: "Server error 500 when updating profile. 
Happens consistently. Need urgent fix."
```

### Example 5: Collaboration
```
Type: Link  
URL: https://figma.com/file/abc123
Description: "Prototype for new feature. Please test 
and provide feedback by EOD."
```

---

## ✅ Quick Reference Card

| Type | Icon | Use For | Max Size | Format |
|------|------|---------|----------|--------|
| Text | 📝 | Quick updates | Unlimited | Plain text |
| Link | 🔗 | External resources | N/A | Any URL |
| File | 📎 | Documents/Images | 10MB* | PDF, DOC, etc |

\* Recommended limit

---

## 🎉 Benefits of New Features

### Before v2.1:
- ❌ Only text comments
- ❌ Files shared via email
- ❌ Links copy-pasted in text
- ❌ Context often lost

### After v2.1:
- ✅ Rich comment types
- ✅ Files attached directly
- ✅ Links with previews
- ✅ Everything in one place
- ✅ Better organization
- ✅ Professional presentation

---

## 📞 Need Help?

**For technical issues**:
- Contact your manager
- Check BUG_FIXES_V2.1.md for details

**For feature requests**:
- Discuss with team lead
- Suggest improvements

**For training**:
- This guide
- Ask experienced team members
- Practice on test tasks

---

## 🚀 Start Using Today!

1. Update TaskFlow to v2.1
2. Open any assigned task
3. Try all three comment types
4. See the difference!

**Happy collaborating! 📱✨**

---

**Version**: 2.1  
**Last Updated**: November 26, 2025  
**Difficulty**: ⭐ Easy (5 minutes to learn)  
**Impact**: ⭐⭐⭐⭐⭐ Game-changer!

