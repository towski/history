var EventListItem = Class.extend({
  init: function(event) {
    this.event = event;
  },

  toLi: function(){
    var li = $(document.createElement('li'))
    var div = $(document.createElement('div'))
    li.attr("created_time", this.event.created_time)
    li.attr("post_id", this.event.post_id)
    li.attr("class", "event")
    div.attr("uid", this.event.actor_id)
    div.attr("size", "square")
    div.attr("class", "eventPic")
    li.append(div)
    var commentsUl = $(document.createElement('ul'))
    if(this.event.comments.count > 0){
      $(this.event.comments.comment_list).each(function(index, comment){
        commentsUl.append("<li>&nbsp;"+comment.text+"</li>")
      });
    }
    var attachmentDiv = $(document.createElement('div'))
    var attachment = this.event.attachment
    if(attachment.description != ""){
      var media = attachment.media[0];
      if(media && media.type == "photo"){
        attachmentDiv.append("<a href='"+media.href+"'><img src='"+media.src+"'/></a>")
      }
      attachmentDiv.append("<br/> "+attachment.description)
      li.append(attachmentDiv)
    }
    li.append("\
    <div> \
      <fb:name uid='"+this.event.actor_id+"'/>&nbsp;"+this.event.message+" \
    </div>");
    li.append(commentsUl)
    return li;
  }
})

var History = Class.extend({
  init: function(friend_id, user_id) {
    this.friend_id = friend_id;
    this.user_id = user_id;
  },

  firstUrl: function(){
    return '/history/'+this.friend_id+'/'+this.user_id
  },

  secondUrl: function(){
    return '/history/'+this.user_id+'/'+this.friend_id
  },

  getUserFriendHistory: function(callback){
    $.getJSON(this.firstUrl(), function(events){ callback(events); $('#loading').hide() })
  },

  getFriendUserHistory: function(callback){
    $.getJSON(this.secondUrl(), function(events){ callback(events); $('#loading_friends').hide(); })
  },

  getComments: function(callback){
    $.getJSON("/comments/"+this.user_id+"/"+this.friend_id, function(events){ callback(events); $('#loading_friends').hide(); })
  },

  getFriendsComments: function(callback){
    $.getJSON("/comments/"+this.friend_id+"/"+this.user_id, function(events){ callback(events); $('#loading_friends').hide(); })
  },

  addHistory: function(events){
    events = $(events)
    var list = $("ul#history li")
    events.each(function(index, event){
      var eventPlaced = false;
      if(list.length == 0){
        var li = new EventListItem(event)
        $("ul#history").append(li.toLi());
      } else{
        while(!eventPlaced){
          var head = $(list[0])
          if(head == null || list.length == 0){
            var li = new EventListItem(event)
            $("ul#history").append(li.toLi());
            eventPlaced = true;
          }else if(head.attr('created_time') < event.created_time){
            var li = new EventListItem(event)
            head.before(li.toLi());
            eventPlaced = true;
          }else{
            list.splice(0,1)
          }
        }
      }
    });
    $('div.eventPic').each(function(index,div){ 
      FB.XFBML.Host.addElement(new FB.XFBML.ProfilePic(div));
    });
  },

  run: function(){
    this.getUserFriendHistory(this.addHistory)
    this.getFriendUserHistory(this.addHistory)
    this.getComments(this.addHistory)
    this.getFriendsComments(this.addHistory)
  }
});
