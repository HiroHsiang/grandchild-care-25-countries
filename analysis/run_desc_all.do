clear all
set more off
foreach c in klosa mhas charls elsa hrs share {
    global COH `c'
    do "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/24_descriptives.do"
}
