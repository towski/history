var EventListItem = Class.extend({
  init: function(event) {
    this.event = event;
  },

  toLi: function(){
    var li = $(document.createElement('li'))
    var div = $(document.createElement('div'))
    li.attr("created_time", this.event.created_time)
    div.attr("uid", this.event.actor_id)
    div.attr("size", "square")
    div.attr("class", "eventPic")
    li.append(div)
    li.append("\
    <div> \
      <fb:name uid='"+this.event.actor_id+"'/>"+this.event.message+" \
    </div>");
    return li;
  }
})

var History = Class.extend({
  init: function(friend_id) {
    this.friend_id = friend_id;
  },

  getUserFriendHistory: function(callback){
    $.getJSON('/history/'+this.friend_id, callback)
  },

  getFriendUserHistory: function(callback){
    $.getJSON('/friend_history/'+this.friend_id, callback)
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
          if(head == null){
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
  }
});
