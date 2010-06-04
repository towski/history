var EventListItem = Class.extend({
  init: function(event) {
    this.event = event;
  },

  toLi: function(){
    var li = $(document.createElement('li'))
    li.html("\
    <div> \
      <fb:profile-pic uid='"+this.event.actor_id+"'/> \
    </div> \
    <div> \
      <fb:name uid='"+this.event.actor_id+"'/>"+this.event.message+" \
    </div>");
    return li;
  }
})

function addHistory(events){
  events = $(events)
  events.each(function(index, event){
    var li = new EventListItem(event)
    $('ul#history').append(li.toLi());
  });
}

$(document).ready(function(){
  var ul = $(document.createElement('ul'))
  ul.attr('id','history')
  $('body').append(ul)
});
