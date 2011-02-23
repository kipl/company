function objectsFromInput(input) {
  this.form = $(input).parents('form');
  this.container = $('#draggables_for_'+this.form.attr('id'));
  this.li = $(input).parents('li');
}
var Burndown = {
  refresh: function() {
    var location_parts, iteration_id;
    location_parts = location.href.split('/');
    iteration_id = location_parts[location_parts.length - 1];
    project_id = location_parts[location_parts.length - 3];
    $('#burndown img').attr('src',
                            '/projects/' + project_id +
                            '/iterations/' + iteration_id +
                            '/burndown?width=350&' + new Date().getTime());
  }
}
function DraggableStories() {
  DraggableStories.labelColumns();
  DraggableStories.create();

  // handle resize event
  $(window).resize(function() {
    DraggableStories.create();
    DraggableStories.recently_resized = true;
    setTimeout('DraggableStories.recently_resized = false', 100);
  });
}

DraggableStories.statuses = [];

DraggableStories.create = function() {
  var full_width, container, height;

  if (DraggableStories.recently_resized) return false;

  // size div
  full_width = $(window).width();
  if (full_width < 831) {
    $('#burndown').hide();
    full_width += 370;
  } else {
    $('#burndown').show();
  }
  $('#stories').width(full_width - 430);

  // remove all existing JSy elements
  $('#draggables_container').remove();

  // make a container for all draggables
  $('ol.stories').before('<div id="draggables_container"></div>');

  container = $('#draggables_container');

  // make draggable container for each form
  $('ol.stories form').each( function() {
    container.append('<div id="draggables_for_'+this.id+'" class="draggables"></div>');
  });

  // make droppables for each radio button
  DraggableStories.droppables = $.map($('input[name="story[status]"]'), function(input, i) {
    return new DroppableStatus(input);
  });

  DraggableStories.draggables = $.map($('input[name="story[status]"]:checked'), function(input, i) {
    return new DraggableStory(input);
  });

  // set height of each row to the height of the draggable content
  $('.draggables').each( function() {
    height = $(this).find('.story .story_content').height() + 9;

    $(this).height(height);
    $(this).find('.ui-droppable').height(height);
  });

  // set positions on each draggable
  $(DraggableStories.draggables).each( function() {
    this.setPosition();
  });

  DraggableStories.scheduleRefresh();
}

DraggableStories.scheduleRefresh = function() {
  clearTimeout(DraggableStories.timeout);
  if (DraggableStories.refreshedOnce) {
    DraggableStories.timeout = setTimeout('DraggableStories.refresh()', 5000);
  } else {
    DraggableStories.timeout = setTimeout('DraggableStories.refresh()', 0);
    DraggableStories.refreshedOnce = true;
  }
}

DraggableStories.refresh = function() {
  var url, stories, statuses, droppable, draggable_story;

  if (DraggableStories.refresh_lock) {
    DraggableStories.scheduleRefresh();
    return false;
  }

  url = window.location.href.split('#')[0] + '/stories.json';

  $.getJSON(url,
    function(stories) {
      statuses = $.map(stories, function(obj) {
        return obj.status;
      });
      if (!DraggableStories.statuses.compare(statuses)) {
        DraggableStories.statuses = statuses;
        $(stories).each( function(i) {
          draggable_story = DraggableStories.draggables[i];
          draggable_story.story.id = this.id;
          draggable_story.story.status = this.status;
          draggable_story.setStatus();
          draggable_story.setPosition();
        });
        Burndown.refresh();
      }
    }
  );

  DraggableStories.scheduleRefresh();
  return false;
}

// make headings based on first set of labels
DraggableStories.labelColumns = function() {
  var html = '<div id="headings"><ol>';

  $($('form.edit_story')[0]).find('label').each( function() {
    var content = $(this).html();
    var label_for = $(this).attr('for');
    var class_name = $('#'+label_for).val();

    html += '<li class="'+class_name+'">'+content+'</li>';
  });
  html += '</ol></div>';

  $('ol.stories').before(html);
}

function DraggableStory(input) {
  var id, id_parts, classes, droppable, droppable_position, objects, content, acceptance_criteria, container;

  this.input = input;
  id_parts = this.input.id.split('_');

  this.story = {
    'id': id_parts[id_parts.length - 1],
    'status': $(input).val()
  }

  objects = new objectsFromInput(input);

  content = objects.li.find('.story_content');
  acceptance_criteria = objects.li.find('.acceptance_criteria');
  container = objects.container;

  droppable = this.droppable();
  droppable_position = droppable.position();
  droppable.addClass('ui-state-highlight');

  classes = 'story';
  if (objects.li.hasClass('with_team')) {
    classes += ' with_team';
  }

  container.append('<div class="'+classes+'" id="draggable_'+
      this.input.id+
      '"><div class="story_content">'+
      content.html()+
      '</div></div>');

  this.element = $('#draggable_' + this.input.id);

  if (acceptance_criteria[0]) {
    this.element.find('.story_content').append('<div class="acceptance_criteria">'+
        acceptance_criteria.html()+
        '</div>');
  }

  this.element.draggable({
      revert: 'invalid',
      axis: 'x',
      containment: 'parent',
      cursor: 'pointer'
    })
    .css('position', 'absolute')
    .width(droppable.width());

  this.setStatus();
}
DraggableStory.prototype = {
  droppable: function() {
    return $('#droppable_story_status_' + this.story.status + '_' + this.story.id);
  },

  setPosition: function() {
    var droppable_position = this.droppable().position();
    this.element
      .css('top', droppable_position.top)
      .css('left', droppable_position.left);
  },

  setStatus: function() {
    Story.setStatus(this.element, this.story.status);
  }
}

function DroppableStatus(input) {
  var instance = this;
  this.input = input;
  var objects = new objectsFromInput(input);
  this.form = objects.form;
  this.container = objects.container;
  this.li = objects.li;
  this.status = $(input).val();

  this.container.append('<div class="'+this.status+'" id="droppable_' + input.id + '"></div>');

  this.droppable = $('#droppable_' + input.id);
  this.droppable
    .droppable({
      drop: function(ev, ui) {
        var id_parts = instance.input.id.split('_');
        var story_id = id_parts[id_parts.length - 1];

        // set the refresh lock to avoid out-of-sync updates
        DraggableStories.refresh_lock = true;

        // check the radio button
        $('li#story_'+story_id+' ol input').val([instance.status]);

        // send the request
        instance.form.ajaxSubmit({
          success: function() {
            DroppableStatus.previous_statuses[story_id] = instance.status;

            // clear refresh lock
            DraggableStories.refresh_lock = false;
          }
        });

        // change class of elements
        var draggable = instance.container.find('.ui-draggable');
        Story.setStatus(draggable, instance.status);

        // custom snapping
        $(ui.draggable)
          .css('left', $(this).position().left)
          .css('top', $(this).position().top);
      }
    });
}

DroppableStatus.previous_statuses = {};
