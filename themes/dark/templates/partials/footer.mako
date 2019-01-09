<%!
    from datetime import datetime
    from time import time
    from contextlib2 import suppress
    import os
    import re
    from medusa import app
    from medusa.helper.common import pretty_file_size
    from medusa.sbdatetime import sbdatetime
    from medusa.show.show import Show

    mem_usage = None
    with suppress(ImportError):
        from psutil import Process
        from os import getpid
        mem_usage = 'psutil'

    with suppress(ImportError):
        if not mem_usage:
            import resource # resource module is unix only
            mem_usage = 'resource'
%>
<!-- BEGIN FOOTER -->
% if loggedIn:
    <%
        stats = Show.overall_stats()
        ep_downloaded = stats['episodes']['downloaded']
        ep_snatched = stats['episodes']['snatched']
        ep_total = stats['episodes']['total']
        ep_percentage = '' if ep_total == 0 else '(<span class="footerhighlight">%s%%</span>)' % re.sub(r'(\d+)(\.\d)\d+', r'\1\2', str((float(ep_downloaded)/float(ep_total))*100))
    %>
    <footer>
        <div class="footer clearfix">
            <span class="footerhighlight">${stats['shows']['total']}</span> Shows (<span class="footerhighlight">${stats['shows']['active']}</span> Active)
            | <span class="footerhighlight">${ep_downloaded}</span>
            % if ep_snatched:
            <span class="footerhighlight"><app-link href="manage/episodeStatuses?whichStatus=2" title="View overview of snatched episodes">+${ep_snatched}</app-link></span> Snatched
            % endif
            &nbsp;/&nbsp;<span class="footerhighlight">${ep_total}</span> Episodes Downloaded ${ep_percentage}
            | Daily Search: <span class="footerhighlight">${str(app.daily_search_scheduler.timeLeft()).split('.')[0] if app.daily_search_scheduler else "<font color='#FF0000'><b>(disabled)</b></font>"}</span>
            | Backlog Search: <span class="footerhighlight">${str(app.backlog_search_scheduler.timeLeft()).split('.')[0] if app.backlog_search_scheduler else "<font color='#FF0000'><b>(disabled)</b></font>"}</span>
            <div>
            % if mem_usage:
                Memory used: <span class="footerhighlight">
                % if mem_usage == 'resource':
                    ${pretty_file_size(resource.getrusage(resource.RUSAGE_SELF).ru_maxrss)}
                % else:
                    ${pretty_file_size(Process(getpid()).memory_info().rss)}
                % endif
                </span> |
            % endif
                Load time: <span class="footerhighlight">${"%.4f" % (time() - sbStartTime)}s</span> / Mako: <span class="footerhighlight">${"%.4f" % (time() - makoStartTime)}s</span> |
                Branch: <span class="footerhighlight">${app.BRANCH}</span> |
                Now: <span class="footerhighlight">${sbdatetime.now().sbfdatetime(d_preset=app.DATE_PRESET, t_preset=app.TIME_PRESET)}</span>
            </div>
        </div>
    </footer>
% endif
<!-- END FOOTER -->
