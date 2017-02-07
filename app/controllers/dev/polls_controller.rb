class Dev::PollsController < Dev::BaseController
  include Dev::PollsHelper

  def test_activity_items
    user = fake_user
    group = saved fake_group
    group.add_admin! user
    discussion = saved fake_discussion(group: group)

    sign_in user
    create_activity_items(discussion: discussion, actor: user)
    redirect_to discussion_url(discussion)
  end

  def test_new_poll_email
    discussion = fake_discussion(group: create_group_with_members)
    actor = discussion.group.admins.first
    PollService.create(poll: fake_poll(discussion: discussion, make_announcement: true), actor: actor)
    last_email
  end

  # TODO: make this not broken
  # def test_poll_edited_email
  #   discussion = fake_discussion(group: create_group_with_members)
  #   actor      = discussion.group.admins.first
  #   PollService.update(
  #     poll: saved(fake_poll(discussion: discussion)),
  #     params: {make_announcement: true, title: "Some other title"},
  #     actor: actor)
  #   last_email
  # end

  def test_poll_closing_soon_email
    discussion = saved(fake_discussion(group: create_group_with_members))
    actor      = discussion.group.admins.first
    poll       = create_fake_poll_with_stances(discussion: discussion,
                                               closing_at: 1.day.from_now)
    PollService.publish_closing_soon
    last_email
  end

  def test_poll_closing_soon_yours_email
    poll = create_fake_poll_with_stances
    render_poll_email(poll, 'poll_closing_soon_yours')
  end

  def test_poll_expired_email
    discussion = fake_discussion(group: create_group_with_members)
    actor      = discussion.group.admins.first
    poll       = create_fake_poll_with_stances(discussion: discussion,
                                               closing_at: 1.day.ago)
    PollService.expire_lapsed_polls
    last_email
  end

  def test_poll_closed_by_user_email
    discussion = fake_discussion(group: create_group_with_members)
    actor      = discussion.group.admins.first
    poll       = saved(fake_poll(discussion: discussion, author: actor))
    PollService.close(poll: poll, actor: actor)
    last_email
  end

  def test_poll_outcome_created_email
    discussion = saved(fake_discussion(group: create_group_with_members))
    actor      = discussion.group.admins.first
    poll       = create_fake_poll_with_stances(discussion: discussion,
                                               closed_at: 1.day.ago,
                                               closing_at: 1.day.ago)
    outcome    = fake_outcome(poll: poll, make_announcement: true)
    OutcomeService.create(outcome: outcome, actor: actor)
    last_email
  end

  def test_proposal_created_email
    discussion = fake_discussion(group: create_group_with_members)
    actor = discussion.group.admins.first
    PollService.create(poll: fake_poll(discussion: discussion, poll_type: 'proposal', make_announcement: true), actor: actor)
    last_email
  end

  def test_proposal_closed_email
    discussion = fake_discussion(group: create_group_with_members)
    actor      = discussion.group.admins.first
    poll       = saved(fake_poll(poll_type: 'proposal', discussion: discussion, author: actor))
    PollService.close(poll: poll, actor: actor)
    last_email
  end
end