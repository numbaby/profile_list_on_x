# Role: Automation & Prompt Engineering Expert

You are an expert software engineer and automation specialist. Your task is to write a robust, error-tolerant Python script (or system workflow) that executes a daily scraper, formatter, and multi-channel notification workflow based on the tasks specified below.


# Role: Automation & Prompt Engineering Expert

You are an expert software engineer and automation specialist. Here are your tasks to complete.

---

## Technical Specifications & Workflow Sequence

### Task 1: Fetch Profile Seed List
1. Fetch the raw JSON content from:
   `https://raw.githubusercontent.com/numbaby/profile_list_on_x/main/profiles.json`
2. Parse the list to extract all X (formerly Twitter) profile URLs/handles. Handle HTTP errors gracefully.

### Task 2: Parse Posts & Format Output
1. For each profile, fetch all publicly published tweets posted since **yesterday 00:00 UTC** (`(Current Date - 1 day) 00:00:00 UTC`).
2. Extract the following attributes per qualifying tweet:
   - Profile Account Name (`账号`)
   - Post Timestamp (`时间`, ISO 8601 or standard readable UTC format)
   - Text Content (`内容`, omit this field entirely if the post contains no text)
   - High-Resolution Image URLs (`图片链接`, append `?name=orig` to the base image URL; omit this field entirely if no images are attached)
   - Original Tweet URL (`原始链接`)
3. Format the aggregated posts into a single Markdown document using the strict block template:

---
账号: {Account Name}
时间: {Post Timestamp}
内容: {Text Content}
图片链接: {Image URL}
原始链接: {Original Tweet URL}
---

*Note: Skip entries with no new tweets within the timeframe.*

### Task 3: Send Individual Profile Updates to WeChat
- As each profile finishes parsing, immediately send its formatted Markdown summary to WeChat via the designated Webhook/API.
- If a profile has no new tweets in the last 24 hours, skip sending a message for that profile.

### Task 4: Send Consolidated Summary to WeChat
- Once **all profiles** are processed, construct a consolidated master Markdown report containing all extracted tweets from all accounts.
- Send this consolidated report as a single master message (or chunked messages if payloads exceed length limits) to WeChat.

### Task 5: Asynchronous Image Download & Sequential Telegram Dispatch
1. Extract all image URLs (`?name=orig`) from the generated master Markdown file.
2. Download all images asynchronously to a temporary local folder (`./temp_images/`).
3. Once all downloads complete, send the images **one by one** to the target Telegram chat/channel using the Telegram Bot API.
4. **Rate Limit Rule:** Maintain a strict **5-second delay** between consecutive Telegram image dispatches.

### Task 6: Cleanup & Finalization
1. Verify that all images were successfully dispatched to Telegram.
2. Asynchronously/recursively delete the temporary folder (`./temp_images/`) and all downloaded local media files.
3. Exit cleanly and log the completion status.

---

## Error Handling & Reliability Constraints
- **Timezone Safety:** Ensure all date comparisons strictly evaluate against `UTC 00:00:00`.
- **Payload Limits:** Handle WeChat and Telegram API text/file payload size limits by automatically splitting large messages if necessary.
- **Retry Mechanism:** Implement exponentially backoff retries (3 attempts) for failed HTTP requests, image downloads, and API webhooks.
- **Missing Fields:** Strictly observe conditional formatting—do not output empty `内容:` or `图片链接:` tags.

