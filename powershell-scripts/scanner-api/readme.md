PowerShell script to export complete tenant metadata using scanner API

For larger tenants, you need to throttle the requests and I'd recommend to query the scan page by page, querying one page, waiting until it's done, then downloading that page, only then query the next page and so on.
