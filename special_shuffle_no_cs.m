% ## Copyright (C) 2023 athil
% ##
% ## This program is free software: you can redistribute it and/or modify
% ## it under the terms of the GNU General Public License as published by
% ## the Free Software Foundation, either version 3 of the License, or
% ## (at your option) any later version.
% ##
% ## This program is distributed in the hope that it will be useful,
% ## but WITHOUT ANY WARRANTY; without even the implied warranty of
% ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% ## GNU General Public License for more details.
% ##
% ## You should have received a copy of the GNU General Public License
% ## along with this program.  If not, see <https://www.gnu.org/licenses/>.
% 
% ## -*- texinfo -*-
% ## @deftypefn {} {@var{retval} =} special_shuffle (@var{input1}, @var{input2})
% ##
% ## @seealso{}
% ## @end deftypefn
% 
% ## Author: athil <athil@athil-X510UNR>
% ## Created: 2023-08-28
function shuffle_list = special_shuffle_no_cs(cond_num,trial_per_cond)


unshuffled_list = repmat(1:cond_num,trial_per_cond,1);
unshuffled_list = reshape(unshuffled_list, cond_num * trial_per_cond,1)';
temp_list = unshuffled_list;
shuffle_list = zeros(size(temp_list));
rand_id = randi([trial_per_cond + 1, trial_per_cond* cond_num],1);
shuffle_list(1) = temp_list(rand_id);
temp_list(rand_id) = [];

rand_id = randi(length(temp_list),1);
shuffle_list(2) = temp_list(rand_id);
temp_list(rand_id) = [];

for i = 3: length(unshuffled_list)
  rand_id = randi(length(temp_list),1);
  shuffle_list(i) = temp_list(rand_id);
  if shuffle_list(i-1) == shuffle_list(i-2)
    double_cond = shuffle_list(i-2);
    while shuffle_list(i) == double_cond
      rand_id = randi(length(temp_list),1);
      shuffle_list(i) = temp_list(rand_id);
    end
  end
  temp_list(rand_id) = [];
end

end
